use std::collections::HashMap;
use std::sync::Mutex;

use crate::layout::{LayoutManager, LayoutMode};
use crate::state::save_preferences;
use crate::AppState;

/// Opens the secure chat window/webview. Delegates to the active layout manager.
#[tauri::command]
pub async fn open_secure_chat(
    app: tauri::AppHandle,
    app_state: tauri::State<'_, Mutex<AppState>>,
) -> Result<(), String> {
    let mut state = app_state.lock().map_err(|e| e.to_string())?;
    state.layout_manager.open_chat(&app)
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
    app: tauri::AppHandle,
    app_state: tauri::State<'_, Mutex<AppState>>,
) -> Result<crate::layout::split_pane::SplitDimensions, String> {
    let state = app_state.lock().map_err(|e| e.to_string())?;
    match &state.layout_manager {
        LayoutManager::SplitPane(l) => l.resize_start(&app),
        _ => Err("Not in split-pane mode".into()),
    }
}

/// Ends a split-pane resize drag.
#[tauri::command]
pub async fn split_resize_end(
    app: tauri::AppHandle,
    app_state: tauri::State<'_, Mutex<AppState>>,
    ratio: f64,
) -> Result<(), String> {
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
