use std::collections::HashMap;
use std::sync::Mutex;

use crate::layout::LayoutMode;
use crate::state::save_preferences;
use crate::AppState;

/// Forward a JS console message to Rust's log output.
#[tauri::command]
pub fn js_log(level: String, msg: String) {
    match level.as_str() {
        "error" => log::error!("[JS] {}", msg),
        "warn"  => log::warn!("[JS] {}", msg),
        _ =>       log::info!("[JS] {}", msg),
    }
}

/// Opens the secure chat window/webview. Delegates to the active layout manager.
#[tauri::command]
pub async fn open_secure_chat(
    app: tauri::AppHandle,
    app_state: tauri::State<'_, Mutex<AppState>>,
) -> Result<(), String> {
    let mut state = app_state.lock().map_err(|e| e.to_string())?;
    state.layout_manager.open_chat(&app)?;
    start_chat_watchdog(app, 10);
    Ok(())
}

/// Returns the current layout mode as a string ("multi-window", "split-pane", "tab-based").
#[tauri::command]
pub async fn get_layout_mode(
    app_state: tauri::State<'_, Mutex<AppState>>,
) -> Result<String, String> {
    let state = app_state.lock().map_err(|e| e.to_string())?;
    Ok(state.layout_manager.mode().as_str().to_string())
}

/// Switches the layout mode at runtime.
#[tauri::command]
pub async fn set_layout_mode(
    app: tauri::AppHandle,
    app_state: tauri::State<'_, Mutex<AppState>>,
    mode: String,
) -> Result<(), String> {
    let new_mode = LayoutMode::from_str(&mode).ok_or("Invalid layout mode")?;
    let mut state = app_state.lock().map_err(|e| e.to_string())?;
    state.preferences.layout_mode = mode;
    save_preferences(&app, &state.preferences);
    let prefs = state.preferences.clone();
    state.layout_manager.switch_mode(&app, new_mode, &prefs)
}

/// Switches the active tab (tab-based mode only). No-op in other modes.
#[tauri::command]
pub async fn switch_tab(
    app: tauri::AppHandle,
    app_state: tauri::State<'_, Mutex<AppState>>,
    tab: String,
) -> Result<(), String> {
    let mut state = app_state.lock().map_err(|e| e.to_string())?;
    state.layout_manager.switch_tab(&app, &tab)
}

/// Returns the currently active tab name ("main" or "chat").
#[tauri::command]
pub async fn get_active_tab(
    app_state: tauri::State<'_, Mutex<AppState>>,
) -> Result<String, String> {
    let state = app_state.lock().map_err(|e| e.to_string())?;
    Ok(state.layout_manager.active_tab().to_string())
}

/// Begins a split-pane resize drag.
#[tauri::command]
pub async fn split_resize_start(
    #[allow(unused_variables)] app: tauri::AppHandle,
    #[allow(unused_variables)] app_state: tauri::State<'_, Mutex<AppState>>,
) -> Result<crate::layout::SplitDimensions, String> {
    #[cfg(desktop)]
    {
        use crate::layout::LayoutManager;
        let state = app_state.lock().map_err(|e| e.to_string())?;
        match &state.layout_manager {
            LayoutManager::SplitPane(l) => l.resize_start(&app),
            _ => Err("Not in split-pane mode".into()),
        }
    }
    #[cfg(mobile)]
    Err("Not available on mobile".into())
}

/// Ends a split-pane resize drag.
#[tauri::command]
pub async fn split_resize_end(
    #[allow(unused_variables)] app: tauri::AppHandle,
    #[allow(unused_variables)] app_state: tauri::State<'_, Mutex<AppState>>,
    #[allow(unused_variables)] ratio: f64,
) -> Result<(), String> {
    #[cfg(desktop)]
    {
        use crate::layout::LayoutManager;
        let mut state = app_state.lock().map_err(|e| e.to_string())?;
        match &mut state.layout_manager {
            LayoutManager::SplitPane(l) => {
                l.resize_end(&app, ratio);
                state.preferences.split_ratio = l.split_ratio;
                save_preferences(&app, &state.preferences);
                Ok(())
            }
            _ => Err("Not in split-pane mode".into()),
        }
    }
    #[cfg(mobile)]
    Err("Not available on mobile".into())
}

/// Starts the SSE notification listener.
#[tauri::command]
pub async fn start_notifications(
    app: tauri::AppHandle,
    app_state: tauri::State<'_, Mutex<AppState>>,
    instance_url: String,
    token: String,
) -> Result<(), String> {
    use crate::notifications::NotificationListener;
    let mut state = app_state.lock().map_err(|e| e.to_string())?;
    if let Some(listener) = state.notification_listener.take() {
        listener.stop();
    }
    state.notification_listener =
        Some(NotificationListener::start(app.clone(), instance_url, token));
    Ok(())
}

/// Stops the SSE notification listener.
#[tauri::command]
pub async fn stop_notifications(
    app_state: tauri::State<'_, Mutex<AppState>>,
) -> Result<(), String> {
    let mut state = app_state.lock().map_err(|e| e.to_string())?;
    if let Some(listener) = state.notification_listener.take() {
        listener.stop();
    }
    Ok(())
}

/// Show an OS notification from the webview.
#[tauri::command]
pub async fn show_notification(
    app: tauri::AppHandle,
    title: String,
    body: String,
) -> Result<(), String> {
    use tauri_plugin_notification::NotificationExt;
    app.notification()
        .builder()
        .title(&title)
        .body(&body)
        .show()
        .map_err(|e: tauri_plugin_notification::Error| e.to_string())
}

/// HTTP fetch via Rust (bypasses WebKit network restrictions).
#[tauri::command]
pub async fn fetch_url(
    url: String,
    method: Option<String>,
    headers: HashMap<String, String>,
    body: Option<String>,
) -> Result<serde_json::Value, String> {
    let client = reqwest::Client::new();
    let m = method.as_deref().unwrap_or("GET");
    let mut req = match m {
        "POST" => client.post(&url),
        "PUT" => client.put(&url),
        "PATCH" => client.patch(&url),
        "DELETE" => client.delete(&url),
        "HEAD" => client.head(&url),
        _ => client.get(&url),
    };
    for (k, v) in &headers {
        req = req.header(k.as_str(), v.as_str());
    }
    if let Some(b) = body {
        req = req.body(b);
    }
    let res = req.send().await.map_err(|e| e.to_string())?;
    let status = res.status().as_u16();
    let resp_headers: HashMap<String, String> = res
        .headers()
        .iter()
        .map(|(k, v)| (k.to_string(), v.to_str().unwrap_or("").to_string()))
        .collect();
    let body = res.text().await.map_err(|e| e.to_string())?;
    Ok(serde_json::json!({
        "status": status,
        "headers": resp_headers,
        "body": body
    }))
}

/// Returns the skip-storage scope string ("all", "messages", etc.) and clears the flag.
/// Returns null/None if no flag is set.
#[tauri::command]
pub fn check_skip_storage(app: tauri::AppHandle) -> Option<String> {
    use tauri::Manager;
    let path = app.path().app_data_dir().ok()?.join(".skip_storage");
    if path.exists() {
        let scope = std::fs::read_to_string(&path).unwrap_or_else(|_| "all".into()).trim().to_string();
        let _ = std::fs::remove_file(&path);
        Some(scope)
    } else {
        None
    }
}

static CRASH_DIALOG_SHOWN: std::sync::atomic::AtomicBool =
    std::sync::atomic::AtomicBool::new(false);
static CHAT_READY: std::sync::atomic::AtomicBool =
    std::sync::atomic::AtomicBool::new(false);

/// Called from JS when the chat view has fully initialized successfully.
/// Cancels the frozen-webview watchdog and resets the crash dialog dedup flag.
#[tauri::command]
pub fn signal_app_ready() {
    CHAT_READY.store(true, std::sync::atomic::Ordering::SeqCst);
    CRASH_DIALOG_SHOWN.store(false, std::sync::atomic::Ordering::SeqCst);
}

/// Start a watchdog: if the chat webview doesn't call signal_app_ready within
/// `timeout_secs`, show a native recovery dialog from Rust — works even if JS is frozen.
pub fn start_chat_watchdog(app: tauri::AppHandle, timeout_secs: u64) {
    use std::sync::atomic::Ordering;
    CHAT_READY.store(false, Ordering::SeqCst);
    let handle = app.clone();
    tauri::async_runtime::spawn(async move {
        tokio::time::sleep(std::time::Duration::from_secs(timeout_secs)).await;
        if CHAT_READY.load(Ordering::SeqCst) {
            return; // JS signalled ready — all good
        }
        if CRASH_DIALOG_SHOWN.swap(true, Ordering::SeqCst) {
            return; // dialog already showing
        }
        use tauri::Manager;
        use tauri_plugin_dialog::{DialogExt, MessageDialogButtons, MessageDialogKind};

        // Step 1: safe fix vs debug
        let clear_wal = handle
            .dialog()
            .message(
                "The chat view is taking too long to load — it may be frozen.\n\n\
                \"Clear DB locks\" releases SQLite locks from an interrupted upload (no data deleted, try this first).\n\n\
                \"Debug options\" lets you reload while skipping specific storage layers to isolate the cause.",
            )
            .title("Chat view not responding")
            .kind(MessageDialogKind::Warning)
            .buttons(MessageDialogButtons::OkCancelCustom(
                "Clear DB locks & start".into(),
                "Debug options…".into(),
            ))
            .blocking_show();

        CRASH_DIALOG_SHOWN.store(false, Ordering::SeqCst);

        if clear_wal {
            crate::clear_sqlite_locks();
            for label in &["chat-webview", "main-webview"] {
                if let Some(wv) = handle.get_webview(label) {
                    let _ = wv.eval("location.reload()");
                }
            }
        } else {
            // Step 2: broad scope
            let skip_attachments = handle
                .dialog()
                .message(
                    "Reload skipping:\n\n\
                    • \"Skip attachments\" — messages load, no attachment files (tests if file serving is the cause)\n\
                    • \"Skip all\" — only group list loads, no messages or attachments",
                )
                .title("Debug: skip storage")
                .kind(MessageDialogKind::Warning)
                .buttons(MessageDialogButtons::OkCancelCustom(
                    "Skip attachments".into(),
                    "Skip all".into(),
                ))
                .blocking_show();

            // Step 3: if skipping attachments, narrow down further
            let scope = if skip_attachments {
                let skip_previews = handle
                    .dialog()
                    .message(
                        "Narrow down further:\n\n\
                        • \"Skip previews\" — files served/decompressed, but thumbnail generation skipped (tests if freeze is in image decoding)\n\
                        • \"Skip files\" — no decompression at all (tests if freeze is in file serving)",
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
            for label in &["chat-webview", "main-webview"] {
                if let Some(wv) = handle.get_webview(label) {
                    let js = format!("sessionStorage.setItem('skipStorage','{}'); location.reload()", scope);
                    let _ = wv.eval(&js);
                }
            }
        }
    });
}

/// Show a native crash-recovery dialog. Called from the JS error handler when the
/// page is in an unrecoverable state. Deduplicates — only the first call per session shows a dialog.
/// If `is_db_corruption` is true, offers to clear local chat data (with a data-loss warning) and reload.
/// Otherwise, shows a plain error with a "Reload" button only.
#[tauri::command]
pub async fn show_crash_dialog(
    app: tauri::AppHandle,
    message: String,
    is_db_corruption: bool,
) -> Result<(), String> {
    use std::sync::atomic::Ordering;
    if CRASH_DIALOG_SHOWN.swap(true, Ordering::SeqCst) {
        return Ok(());
    }
    use tauri::Manager;
    use tauri_plugin_dialog::{DialogExt, MessageDialogButtons, MessageDialogKind};

    let should_clear = if is_db_corruption {
        app.dialog()
            .message(format!(
                "{}\n\n⚠️ Clearing local data will delete your local message history. Your account and encryption keys are NOT affected.\n\nClear local chat data and reload?",
                message
            ))
            .title("Chat database error")
            .kind(MessageDialogKind::Error)
            .buttons(MessageDialogButtons::OkCancelCustom(
                "Clear & reload".into(),
                "Reload without clearing".into(),
            ))
            .blocking_show()
    } else {
        app.dialog()
            .message(message)
            .title("Something went wrong")
            .kind(MessageDialogKind::Error)
            .buttons(MessageDialogButtons::OkCustom("Reload".into()))
            .blocking_show();
        false
    };

    if should_clear {
        crate::clear_chat_storage();
    }

    // Reload the chat webview regardless
    for label in &["chat-webview", "main-webview"] {
        if let Some(wv) = app.get_webview(label) {
            let _ = wv.eval("location.reload()");
        }
    }

    Ok(())
}
