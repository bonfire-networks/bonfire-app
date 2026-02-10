//! Persistence helpers for window geometry and user preferences.
//!
//! Window state is stored in `window-state.json` with mode-prefixed keys
//! (e.g. "multi-window:main") so each layout mode remembers its own geometry.
//! Falls back to legacy unprefixed keys for migration.

use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use std::fs;
use std::path::PathBuf;
use tauri::Manager;

/// Logical position and size of a window, stored in device-independent pixels.
#[derive(Serialize, Deserialize, Clone, Debug)]
pub struct WindowGeometry {
    pub x: f64,
    pub y: f64,
    pub width: f64,
    pub height: f64,
}

/// User preferences persisted to `preferences.json` in the app data directory.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Preferences {
    /// Active layout mode: "multi-window", "split-pane", or "tab-based"
    pub layout_mode: String,
    /// Split ratio for split-pane mode (0.0..1.0, default 0.6)
    #[serde(default = "default_split_ratio")]
    pub split_ratio: f64,
    /// Whether to show the chrome bar in non-tab modes (default: false).
    /// Tab-based mode always shows the chrome bar regardless of this setting.
    #[serde(default)]
    pub show_chrome_bar: bool,
}

fn default_split_ratio() -> f64 {
    0.6
}

impl Default for Preferences {
    fn default() -> Self {
        Self {
            layout_mode: "multi-window".to_string(),
            split_ratio: 0.6,
            show_chrome_bar: false,
        }
    }
}

/// Returns the path to `window-state.json`, creating the directory if needed.
pub fn state_path(app: &tauri::AppHandle) -> PathBuf {
    let dir = app.path().app_data_dir().expect("no app data dir");
    let _ = fs::create_dir_all(&dir);
    dir.join("window-state.json")
}

/// Returns the path to `preferences.json`, creating the directory if needed.
pub fn preferences_path(app: &tauri::AppHandle) -> PathBuf {
    let dir = app.path().app_data_dir().expect("no app data dir");
    let _ = fs::create_dir_all(&dir);
    dir.join("preferences.json")
}

/// Loads all window geometries from disk. Returns empty map on any error.
pub fn load_state(app: &tauri::AppHandle) -> HashMap<String, WindowGeometry> {
    fs::read_to_string(state_path(app))
        .ok()
        .and_then(|s| serde_json::from_str(&s).ok())
        .unwrap_or_default()
}

/// Writes the full window geometry map to disk.
pub fn save_state_map(app: &tauri::AppHandle, state: &HashMap<String, WindowGeometry>) {
    if let Ok(json) = serde_json::to_string_pretty(state) {
        let _ = fs::write(state_path(app), json);
    }
}

/// Captures a WebviewWindow's current position and size, then persists it
/// under the given key (e.g. "multi-window:main"). Accounts for display scaling.
pub fn save_window_geometry(app: &tauri::AppHandle, key: &str, window: &tauri::WebviewWindow) {
    let scale = window.scale_factor().unwrap_or(1.0);
    let Some(pos) = window.outer_position().ok() else {
        return;
    };
    let Some(size) = window.outer_size().ok() else {
        return;
    };

    let geom = WindowGeometry {
        x: pos.x as f64 / scale,
        y: pos.y as f64 / scale,
        width: size.width as f64 / scale,
        height: size.height as f64 / scale,
    };

    let mut state = load_state(app);
    state.insert(key.to_string(), geom);
    save_state_map(app, &state);
}

/// Captures a bare Window's (multi-webview mode) position and size, then persists it.
/// Similar to `save_window_geometry` but for `Window` instead of `WebviewWindow`.
pub fn save_bare_window_geometry(app: &tauri::AppHandle, key: &str, window: &tauri::Window) {
    let scale = window.scale_factor().unwrap_or(1.0);
    let Some(pos) = window.outer_position().ok() else {
        return;
    };
    let Some(size) = window.outer_size().ok() else {
        return;
    };

    let geom = WindowGeometry {
        x: pos.x as f64 / scale,
        y: pos.y as f64 / scale,
        width: size.width as f64 / scale,
        height: size.height as f64 / scale,
    };

    let mut state = load_state(app);
    state.insert(key.to_string(), geom);
    save_state_map(app, &state);
}

/// Loads user preferences from disk. Returns defaults on any error.
pub fn load_preferences(app: &tauri::AppHandle) -> Preferences {
    fs::read_to_string(preferences_path(app))
        .ok()
        .and_then(|s| serde_json::from_str(&s).ok())
        .unwrap_or_default()
}

/// Persists user preferences to disk.
pub fn save_preferences(app: &tauri::AppHandle, prefs: &Preferences) {
    if let Ok(json) = serde_json::to_string_pretty(prefs) {
        let _ = fs::write(preferences_path(app), json);
    }
}

/// Returns the primary monitor's logical size (accounts for Retina/HiDPI scaling).
/// Falls back to 1920x1080 if the monitor cannot be detected.
pub fn logical_screen_size(app: &tauri::AppHandle) -> (f64, f64) {
    app.primary_monitor()
        .ok()
        .flatten()
        .map(|m| {
            let s = m.size();
            let scale = m.scale_factor();
            (s.width as f64 / scale, s.height as f64 / scale)
        })
        .unwrap_or((1920.0, 1080.0))
}

/// Looks up saved geometry for a window, first trying the mode-prefixed key
/// (e.g. "multi-window:main"), then falling back to the bare label ("main")
/// for backward compatibility with pre-layout-mode state files.
pub fn get_geometry(
    app: &tauri::AppHandle,
    mode_prefix: &str,
    label: &str,
) -> Option<WindowGeometry> {
    let state = load_state(app);
    let prefixed_key = format!("{}:{}", mode_prefix, label);
    state
        .get(&prefixed_key)
        .or_else(|| state.get(label))
        .cloned()
}
