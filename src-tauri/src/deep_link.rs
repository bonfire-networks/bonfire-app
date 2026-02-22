use std::sync::Mutex;

use tauri::Manager;
use tauri_plugin_deep_link::DeepLinkExt;

#[cfg(desktop)]
use crate::AppState;

/// Known domains for deep-link handling, stored as managed state.
/// Populated from config at startup and extended dynamically after login (except on MacOS).
pub struct KnownDomains(pub Vec<String>);

impl KnownDomains {
    pub fn contains(&self, host: &str) -> bool {
        self.0.iter().any(|d| d == host)
    }
}

#[derive(Clone, serde::Serialize)]
pub struct DeepLinkPayload {
    pub scheme: String,
    pub group_id: Option<String>,
    pub path: String,
    pub raw_url: String,
    pub target_tab: String,
}

pub fn parse_url(raw: &str, known_domains: Option<&KnownDomains>) -> Option<DeepLinkPayload> {
    let url = url::Url::parse(raw).ok()?;
    let scheme = url.scheme().to_string();

    // For https:// URLs, only handle if domain is known
    if scheme == "https" || scheme == "http" {
        let host = url.host_str().unwrap_or("");
        if let Some(domains) = known_domains {
            if !domains.contains(host) {
                return None;
            }
        }
    }

    // For custom schemes like bonfire://about or bonfire://post/123,
    // the URL parser treats the first segment as the host, not path.
    // Reconstruct the full path from host + path.
    let path = if scheme != "https" && scheme != "http" {
        let host = url.host_str().unwrap_or("");
        let url_path = url.path().trim_start_matches('/');
        if url_path.is_empty() {
            host.to_string()
        } else {
            format!("{host}/{url_path}")
        }
    } else {
        url.path().trim_start_matches('/').to_string()
    };
    let group_id = if scheme == "mls" {
        // Internal MLS ID — reconstruct as mls:// URI for direct IndexedDB lookup
        Some(format!("mls://{path}"))
    } else if scheme == "ap-mls" {
        // Shareable deep link — reconstruct as ap-mls:// URI
        Some(format!("ap-mls://{path}"))
    } else {
        path.split('/')
            .filter(|s| !s.is_empty())
            .last()
            .map(|s| s.to_string())
    };

    let target_tab = match scheme.as_str() {
        "mls" | "ap-mls" => "chat",
        _ => "bonfire",
    }
    .to_string();

    Some(DeepLinkPayload {
        scheme,
        group_id,
        path,
        raw_url: raw.to_string(),
        target_tab,
    })
}

/// Navigate the app to a deep-link target -- all from Rust.
/// Switches to the correct tab, then navigates the webview, and brings
/// the window to the foreground.
#[cfg(desktop)]
pub fn handle(app: &tauri::AppHandle, payload: &DeepLinkPayload) {
    log::info!(
        "[deep-link] Handling: scheme={}, tab={}, path={}, group_id={:?}",
        payload.scheme,
        payload.target_tab,
        payload.path,
        payload.group_id,
    );

    let state_mutex = app.state::<Mutex<AppState>>();
    let Ok(mut state) = state_mutex.lock() else {
        log::error!("[deep-link] Failed to lock AppState");
        return;
    };

    if payload.target_tab == "chat" {
        log::info!("[deep-link] Opening chat tab");
        let _ = state.layout_manager.open_chat(app);
        drop(state);

        // Bring window to foreground
        if let Some(window) = app.get_window("main-window") {
            let _ = window.show();
            let _ = window.set_focus();
        } else if let Some(window) = app.get_window("chat-window") {
            let _ = window.show();
            let _ = window.set_focus();
        }

        if let Some(ref group_id) = payload.group_id {
            let js = format!(
                "if (window.navigateToGroup) window.navigateToGroup({}, {})",
                serde_json::to_string(group_id).unwrap_or_default(),
                serde_json::to_string(&payload.raw_url).unwrap_or_default(),
            );
            if let Some(wv) = app.get_webview("chat-webview") {
                log::info!("[deep-link] Calling navigateToGroup({group_id})");
                let _ = wv.eval(&js);
            } else {
                log::warn!("[deep-link] chat-webview not found");
            }
        }
    } else {
        log::info!("[deep-link] Opening bonfire tab, url={}", payload.raw_url);
        state.layout_manager.show_main(app);
        drop(state);

        // Bring window to foreground
        if let Some(window) = app.get_window("main-window") {
            let _ = window.show();
            let _ = window.set_focus();
        }

        if let Some(wv) = app.get_webview("main-webview") {
            // For bonfire:// scheme, resolve path against webview's current origin
            let path = &payload.path;
            let target_path = format!("/{path}");
            let path_json = serde_json::to_string(&target_path).unwrap_or_default();

            // Check if the webview is on the Phoenix instance (not pick-instance.html)
            let on_instance = wv
                .url()
                .ok()
                .and_then(|u| u.host_str().map(|h| h.to_string()))
                .is_some_and(|h| h != "localhost" && !h.contains("tauri"));

            if on_instance {
                log::info!("[deep-link] LiveView navigate to {target_path}");
                // Use LiveView's live_redirect for smooth same-socket navigation,
                // falling back to location.href for non-LiveView pages
                let js = format!(
                    "{{ var main = document.querySelector('[data-phx-main]'); \
                    if (main && window.liveSocket) {{ \
                        window.liveSocket.redirect({path_json}); \
                    }} else {{ \
                        window.location.href = {path_json}; \
                    }} }}"
                );
                let _ = wv.eval(&js);
            } else {
                // Not on instance yet — cold-start URLs are already stored via
                // get_current() in setup(), so don't re-store here (causes loops).
                log::info!("[deep-link] Webview not on instance, skipping (cold-start handled via get_startup_deep_link)");
            }
        } else {
            log::warn!("[deep-link] main-webview not found");
        }
    }
}

/// On mobile, navigate via the single WebviewWindow (no bare Window/Webview APIs).
#[cfg(mobile)]
pub fn handle(app: &tauri::AppHandle, payload: &DeepLinkPayload) {
    log::info!(
        "[deep-link] Handling on mobile: scheme={}, tab={}, path={}, group_id={:?}",
        payload.scheme,
        payload.target_tab,
        payload.path,
        payload.group_id,
    );

    if let Some(ww) = app.get_webview_window("main") {
        if payload.target_tab == "chat" {
            if let Some(ref group_id) = payload.group_id {
                let js = format!(
                    "if (window.navigateToGroup) window.navigateToGroup({}, {})",
                    serde_json::to_string(group_id).unwrap_or_default(),
                    serde_json::to_string(&payload.raw_url).unwrap_or_default(),
                );
                let _ = ww.eval(&js);
            }
        } else {
            let path = &payload.path;
            let target_path = format!("/{path}");
            let path_json = serde_json::to_string(&target_path).unwrap_or_default();
            let js = format!(
                "{{ var main = document.querySelector('[data-phx-main]'); \
                if (main && window.liveSocket) {{ \
                    window.liveSocket.redirect({path_json}); \
                }} else {{ \
                    window.location.href = {path_json}; \
                }} }}"
            );
            let _ = ww.eval(&js);
        }
    } else {
        log::warn!("[deep-link] WebviewWindow 'main' not found on mobile");
    }
}

// ── Tauri commands ──────────────────────────────────────────────────────────

/// Cold-start deep-link: frontend calls this once after init to check
/// if the app was launched via a deep link.
/// Returns the payload for JS to handle navigation — does NOT call handle()
/// here because the webview is still on pick-instance.html (not on the instance),
/// and handle() would store the payload back, creating a loop.
#[tauri::command]
pub fn get_startup_deep_link(
    _app: tauri::AppHandle,
    state: tauri::State<'_, Mutex<Option<DeepLinkPayload>>>,
) -> Option<DeepLinkPayload> {
    state.lock().ok().and_then(|mut guard| guard.take())
}

/// Register instance domain for https:// deep links (called after login).
/// Adds to both the OS handler and the in-app known domains list.
#[tauri::command]
pub fn register_deep_link_domain(app: tauri::AppHandle, domain: String) -> Result<(), String> {
    app.deep_link()
        .register(&domain)
        .map_err(|e| e.to_string())?;
    let known = app.state::<Mutex<KnownDomains>>();
    if let Ok(mut guard) = known.lock() {
        if !guard.0.contains(&domain) {
            guard.0.push(domain);
        }
    }
    Ok(())
}

/// Register the deep-link plugin and set up URL handling.
/// Called from the Tauri `.setup()` closure after managed state is registered.
pub fn setup(app: &tauri::App) {
    // Read known domains from config and register with the OS
    let mut domain_list: Vec<String> = Vec::new();
    if let Some(bonfire_config) = app.config().plugins.0.get("bonfire") {
        if let Some(domains) = bonfire_config.get("known_domains").and_then(|d| d.as_array()) {
            for domain in domains {
                if let Some(d) = domain.as_str() {
                    domain_list.push(d.to_string());
                    let _ = app.deep_link().register(d);
                }
            }
        }
    }
    app.manage(Mutex::new(KnownDomains(domain_list)));

    // Handle URLs received while app is running
    let handle_for_dl = app.handle().clone();
    app.deep_link().on_open_url(move |event| {
        if let Some(url) = event.urls().first() {
            log::info!("[deep-link] Received: {url}");
            let known = handle_for_dl.state::<Mutex<KnownDomains>>();
            let domains = known.lock().ok();
            let domains_ref = domains.as_deref();
            if let Some(payload) = parse_url(&url.to_string(), domains_ref) {
                handle(&handle_for_dl, &payload);
            }
        }
    });

    // Store cold-start URL for frontend to pick up after init
    let known = app.state::<Mutex<KnownDomains>>();
    let domains = known.lock().ok();
    let domains_ref = domains.as_deref();
    let startup_link: Option<DeepLinkPayload> = app
        .deep_link()
        .get_current()
        .ok()
        .flatten()
        .and_then(|urls| urls.into_iter().next())
        .and_then(|u| parse_url(&u.to_string(), domains_ref));
    app.manage(Mutex::new(startup_link));
}
