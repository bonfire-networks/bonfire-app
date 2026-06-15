mod commands;
mod deep_link;
mod layout;
mod notifications;
mod state;
#[cfg(desktop)]
mod tray;

use std::sync::Mutex;

use layout::{LayoutManager, LayoutMode};
use notifications::NotificationListener;
use state::{load_preferences, Preferences};
use tauri::{Manager, RunEvent};

/// Returns path to the WebKit website data directory for this app.
fn webkit_data_dir() -> Option<std::path::PathBuf> {
    let home = std::env::var("HOME").ok()?;
    Some(std::path::PathBuf::from(home)
        .join("Library/WebKit/cafe.bonfire.desktop/WebsiteData"))
}

/// Delete SQLite WAL/SHM lock files — releases locks without touching message history or MLS keys.
pub fn clear_sqlite_locks() {
    if let Some(home) = std::env::var("HOME").ok() {
        let app_data = std::path::PathBuf::from(home)
            .join("Library/Application Support/cafe.bonfire.desktop");
        if let Ok(entries) = std::fs::read_dir(&app_data) {
            for entry in entries.flatten() {
                let path = entry.path();
                if let Some(ext) = path.extension().and_then(|e| e.to_str()) {
                    if ext == "wal" || ext == "shm" {
                        let _ = std::fs::remove_file(&path);
                    }
                }
            }
        }
    }
}

/// Delete IndexedDB and LocalStorage — clears cached message history without touching MLS keys.
pub fn clear_indexeddb() {
    if let Some(dir) = webkit_data_dir() {
        for sub in &["IndexedDB", "LocalStorage"] {
            let path = dir.join(sub);
            if path.exists() {
                let _ = std::fs::remove_dir_all(&path);
            }
        }
    }
}

/// Delete both SQLite WAL/SHM files and IndexedDB/LocalStorage.
pub fn clear_chat_storage() {
    clear_sqlite_locks();
    clear_indexeddb();
}

/// Path to the startup dirty flag file (in app data dir).
fn dirty_flag_path(app: &tauri::AppHandle) -> Option<std::path::PathBuf> {
    app.path().app_data_dir().ok().map(|d| d.join(".startup_dirty"))
}

fn write_dirty_flag(app: &tauri::AppHandle) {
    if let Some(p) = dirty_flag_path(app) {
        let _ = std::fs::write(&p, b"1");
    }
}

fn clear_dirty_flag(app: &tauri::AppHandle) {
    if let Some(p) = dirty_flag_path(app) {
        let _ = std::fs::remove_file(&p);
    }
}

fn dirty_flag_exists(app: &tauri::AppHandle) -> bool {
    dirty_flag_path(app).is_some_and(|p| p.exists())
}

/// Set to true when an unclean shutdown is detected; read by webview initialization scripts.
pub static JS_DEBUG_MODE: std::sync::atomic::AtomicBool =
    std::sync::atomic::AtomicBool::new(false);

/// Application state managed by Tauri, protected by a Mutex for thread safety.
pub struct AppState {
    pub layout_manager: LayoutManager,
    pub preferences: Preferences,
    pub notification_listener: Option<NotificationListener>,
}

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    let mut builder = tauri::Builder::default()
        .plugin(
            tauri_plugin_log::Builder::default()
                .level(if cfg!(feature = "e2e-testing") {
                    log::LevelFilter::Trace
                } else {
                    log::LevelFilter::Info
                })
                .build(),
        )
        .plugin(tauri_plugin_notification::init())
        .plugin(tauri_plugin_http::init())
        .plugin(tauri_plugin_deep_link::init())
        .plugin(tauri_plugin_dialog::init())
        .invoke_handler(tauri::generate_handler![
            commands::open_secure_chat,
            commands::get_layout_mode,
            commands::set_layout_mode,
            commands::switch_tab,
            commands::get_active_tab,
            commands::show_notification,
            commands::split_resize_start,
            commands::split_resize_end,
            commands::start_notifications,
            commands::stop_notifications,
            commands::fetch_url,
            deep_link::get_startup_deep_link,
            deep_link::register_deep_link_domain,
            commands::show_crash_dialog,
            commands::signal_app_ready,
            commands::check_skip_storage,
            commands::js_log,
        ]);

        // The E2EE chat client (and its MLS plugin) is not part of the iOS build:
        // iOS ships as a pure instance client for now (docs/tauri-mobile.md Q6).
        #[cfg(not(target_os = "ios"))]
        {
            builder = builder.plugin(tauri_plugin_openmls::init());
        }

        // WKWebView's content process can be killed under memory pressure (e.g. long
        // media-heavy feeds on iOS), which otherwise leaves a permanently blank screen.
        #[cfg(any(target_os = "macos", target_os = "ios"))]
        {
            builder = builder.on_web_content_process_terminate(|webview| {
                log::warn!("web content process terminated, reloading webview");
                let _ = webview.reload();
            });
        }

        #[cfg(feature = "e2e-testing")]
        {
            let sock = std::env::var("TAURI_PLAYWRIGHT_SOCK")
                .unwrap_or_else(|_| "/tmp/tauri-playwright.sock".into());
            builder = builder.plugin(
                tauri_plugin_playwright::init_with_config(
                    tauri_plugin_playwright::PluginConfig::new()
                        .socket_path(sock)
                        .window_label("chat-webview")
                )
            );
        }

        let app = builder.setup(move |app| {
            let prefs = load_preferences(app.handle());
            #[allow(unused_variables)]
            let mode = LayoutMode::from_preferences(&prefs);

            #[cfg(all(feature = "e2e-testing", desktop))]
            {
                // E2E mode: skip pick-instance.html, open chat webview directly.
                // Credentials injected via env vars so localStorage is pre-populated
                // before the chat controller initialises.
                let access_token = std::env::var("E2E_ACCESS_TOKEN").unwrap_or_default();
                let app_url_full = std::env::var("E2E_APP_URL").unwrap_or_else(|_| "http://localhost:4000".to_string());
                // appUrl is stored without scheme in localStorage (app prepends https:// itself)
                let app_url = app_url_full.trim_start_matches("https://").trim_start_matches("http://").to_string();
                let actor_id    = std::env::var("E2E_ACTOR_ID").unwrap_or_default();
                let token_ep    = std::env::var("E2E_TOKEN_ENDPOINT").unwrap_or_default();
                let auth_ep     = std::env::var("E2E_AUTH_ENDPOINT").unwrap_or_default();
                // Device ID isolates WebKit storage and IndexedDB per-instance.
                let device_id   = std::env::var("E2E_DEVICE_ID").unwrap_or_default();
                let device_id_stmt = if device_id.is_empty() {
                    "localStorage.removeItem('device_id');".to_string()
                } else {
                    format!("localStorage.setItem('device_id',{});", serde_json::to_string(&device_id).unwrap())
                };
                // Derive a 16-byte data store identifier so each instance gets its own isolated
                // WKWebView data store (separate localStorage, cookies, etc.).
                // Formula: instance_id * 10 + device_num — unique across parallel test runs.
                let device_num: u8 = device_id
                    .trim_start_matches("device-")
                    .parse()
                    .unwrap_or(0);
                let instance_id: u8 = std::env::var("E2E_INSTANCE_ID")
                    .ok()
                    .and_then(|s| s.parse().ok())
                    .unwrap_or(0);
                let store_id: [u8; 16] = {
                    let mut id = [0u8; 16];
                    id[0] = instance_id * 10 + device_num;
                    id
                };
                let init_script = format!(
                    "localStorage.clear();\
                     localStorage.setItem('access_token',{at});\
                     localStorage.setItem('appUrl',{au});\
                     localStorage.setItem('actor_id',{ai});\
                     localStorage.setItem('token_endpoint',{te});\
                     localStorage.setItem('authorization_endpoint',{ae});\
                     localStorage.setItem('wasmBasePath','false');\
                     window.__BONFIRE_JS_DEBUG__=true;\
                     {di}",
                    at = serde_json::to_string(&access_token).unwrap(),
                    au = serde_json::to_string(&app_url).unwrap(),
                    ai = serde_json::to_string(&actor_id).unwrap(),
                    te = serde_json::to_string(&token_ep).unwrap(),
                    ae = serde_json::to_string(&auth_ep).unwrap(),
                    di = device_id_stmt,
                );
                let mut wb = tauri::WebviewWindowBuilder::new(
                    app,
                    "chat-webview",
                    tauri::WebviewUrl::App("assets/ap_c2s_client/index.html".into()),
                )
                .initialization_script(&init_script)
                .inner_size(1280.0, 800.0);
                if !device_id.is_empty() {
                    #[cfg(target_os = "macos")]
                    { wb = wb.data_store_identifier(store_id); }
                    #[cfg(not(target_os = "macos"))]
                    {
                        let webkit_data = app.path().app_data_dir()
                            .map_err(|e| format!("app data dir: {e}"))?
                            .join("webkit");
                        wb = wb.data_directory(webkit_data);
                    }
                }
                wb.build().map_err(|e| format!("E2E chat window failed: {e}"))?;

                let layout_manager = LayoutManager::new(mode, &prefs);
                app.manage(Mutex::new(AppState {
                    layout_manager,
                    preferences: prefs,
                    notification_listener: None,
                }));
                return Ok(());
            }

            #[cfg(all(not(feature = "e2e-testing"), desktop))]
            {
                // Detect unclean shutdown — enable JS debug logging and offer recovery options
                let had_dirty_quit = dirty_flag_exists(app.handle());
                if had_dirty_quit {
                    JS_DEBUG_MODE.store(true, std::sync::atomic::Ordering::SeqCst);
                    use tauri_plugin_dialog::{DialogExt, MessageDialogButtons, MessageDialogKind};
                    let handle = app.handle().clone();
                    let clear_locks = app.dialog()
                        .message(
                            "The app did not shut down cleanly last time.\n\n\
                            \"Clear DB locks\" releases SQLite locks — no data is deleted (try this first).\n\n\
                            \"Debug options\" lets you start while skipping specific storage layers to isolate a freeze.",
                        )
                        .title("Unclean shutdown")
                        .kind(MessageDialogKind::Warning)
                        .buttons(MessageDialogButtons::OkCancelCustom(
                            "Clear DB locks & start".into(),
                            "Debug options…".into(),
                        ))
                        .blocking_show();
                    if clear_locks {
                        clear_sqlite_locks();
                    } else {
                        let skip_attachments = app.dialog()
                            .message(
                                "Start skipping:\n\n\
                                • \"Skip attachments\" — messages load, no attachment files\n\
                                • \"Skip all\" — only group list loads",
                            )
                            .title("Debug: skip storage")
                            .kind(MessageDialogKind::Warning)
                            .buttons(MessageDialogButtons::OkCancelCustom(
                                "Skip attachments".into(),
                                "Skip all".into(),
                            ))
                            .blocking_show();
                        let scope_str = if skip_attachments {
                            let skip_previews = app.dialog()
                                .message(
                                    "Narrow down further:\n\n\
                                    • \"Skip previews\" — files decompressed, thumbnail generation skipped\n\
                                    • \"Skip files\" — no decompression at all",
                                )
                                .title("Debug: attachment scope")
                                .kind(MessageDialogKind::Warning)
                                .buttons(MessageDialogButtons::OkCancelCustom(
                                    "Skip previews".into(),
                                    "Skip files".into(),
                                ))
                                .blocking_show();
                            if skip_previews { "previews" } else { "attachments" }
                        } else {
                            "all"
                        };
                        if let Ok(data_dir) = app.handle().path().app_data_dir() {
                            let _ = std::fs::write(data_dir.join(".skip_storage"), scope_str);
                        }
                    }
                    clear_dirty_flag(&handle);
                }
                write_dirty_flag(app.handle());

                let mut layout_manager = LayoutManager::new(mode, &prefs);
                if let Err(e) = layout_manager.setup(app.handle(), Some("pick-instance.html")) {
                    eprintln!("Layout setup failed: {}", e);
                }
                // Start watchdog if chat webview is created at startup (tab/split modes)
                if layout_manager.has_chat_webview() {
                    commands::start_chat_watchdog(app.handle().clone(), 10);
                }
                app.manage(Mutex::new(AppState {
                    layout_manager,
                    preferences: prefs,
                    notification_listener: None,
                }));
                tray::setup(app, mode)?;
            } // end #[cfg(all(not(feature = "e2e-testing"), desktop))]

            #[cfg(mobile)]
            {
                // Mobile: single WebviewWindow. The shell reads __BONFIRE_PLATFORM__ to
                // pick its code path — UA sniffing can't detect iPads (WKWebView reports
                // macOS). On Android a bottom nav bar is additionally injected on chat
                // pages (Home/Messages tabs); iOS has no chat tab (pure instance client
                // for now) so nothing is injected there.
                use tauri::WebviewUrl;
                let mut wb = tauri::WebviewWindowBuilder::new(
                    app,
                    "main",
                    WebviewUrl::App("pick-instance.html".into()),
                );
                #[cfg(target_os = "android")]
                {
                    wb = wb
                        .initialization_script("window.__BONFIRE_PLATFORM__ = 'android';")
                        .initialization_script(include_str!(
                            "../../extensions/bonfire_ui_common/assets/static/tauri/mobile-nav.js"
                        ));
                }
                #[cfg(target_os = "ios")]
                {
                    wb = wb.initialization_script("window.__BONFIRE_PLATFORM__ = 'ios';");
                }
                let ww = wb
                    .build()
                    .map_err(|e| format!("Mobile window setup failed: {e}"))?;

                // Enable the iOS edge-swipe back/forward gesture. It navigates the
                // webview's own history — which includes LiveView live_patch/live_redirect
                // (pushState) entries — so users can swipe to go back through router history.
                // Tauri exposes no toggle, so set allowsBackForwardNavigationGestures
                // directly on the WKWebView handle via with_webview.
                #[cfg(target_os = "ios")]
                {
                    if let Err(e) = ww.with_webview(|webview| {
                        // objc2-web-kit's WKWebView binding is macOS-only, so message the
                        // iOS WKWebView handle directly. SAFETY: on iOS `inner()` is the
                        // WKWebView; the gesture setter has no preconditions.
                        let view = webview.inner() as *const objc2::runtime::AnyObject;
                        if !view.is_null() {
                            unsafe {
                                let _: () = objc2::msg_send![
                                    &*view,
                                    setAllowsBackForwardNavigationGestures: true
                                ];
                            }
                        }
                    }) {
                        log::warn!("could not enable swipe-back gesture: {e}");
                    }
                }

                let mut layout_manager = LayoutManager::new(LayoutMode::TabBased, &prefs);

                // Capture local asset origin for tab navigation URLs
                let local_origin = ww
                    .url()
                    .ok()
                    .and_then(|url| {
                        url.host_str()
                            .map(|host| format!("{}://{}", url.scheme(), host))
                    })
                    .unwrap_or_else(|| "http://tauri.localhost".to_string());
                layout_manager.set_local_origin(local_origin);

                app.manage(Mutex::new(AppState {
                    layout_manager,
                    preferences: prefs,
                    notification_listener: None,
                }));
            }

            deep_link::setup(app);

            Ok(())
        })
        .build(tauri::generate_context!())
        .expect("Error while building Bonfire app");

    app.run(|#[allow(unused_variables)] app, event| match event {
        RunEvent::ExitRequested { code, api, .. } => {
            if code.is_none() {
                // Last window closed on macOS — keep app alive in dock, clear flag (clean state)
                api.prevent_exit();
                clear_dirty_flag(app);
            } else {
                // Clean exit via app.exit()
                clear_dirty_flag(app);
            }
        }
        RunEvent::Exit => {
            clear_dirty_flag(app);
        }
        #[cfg(desktop)]
        RunEvent::WindowEvent {
            label,
            event: tauri::WindowEvent::CloseRequested { .. },
            ..
        } => {
            let state_mutex = app.state::<Mutex<AppState>>();
            let Ok(state) = state_mutex.lock() else { return };
            state.layout_manager.save_window_by_label(app, &label);
        }
        #[cfg(desktop)]
        RunEvent::WindowEvent {
            label,
            event: tauri::WindowEvent::Resized(_),
            ..
        } => {
            let state_mutex = app.state::<Mutex<AppState>>();
            let Ok(mut state) = state_mutex.lock() else { return };
            state.layout_manager.handle_resize(app, &label);
        }
        _ => {}
    });
}
