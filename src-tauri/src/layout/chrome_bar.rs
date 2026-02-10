//! Chrome bar: a thin HTML webview strip (44px) at the top of single-window modes.
//!
//! Uses standard OS window controls (native traffic lights on macOS, native buttons
//! on Windows/Linux). The HTML only provides:
//! - A drag region for window movement (`data-tauri-drag-region`)
//! - Tab switching buttons (in tab-based mode)
//! - A centered title (when optionally enabled in non-tab modes)
//!
//! Always present in tab-based mode; optional in other modes
//! (controlled by `show_chrome_bar` in preferences, default off).

use tauri::webview::WebviewBuilder;
use tauri::{LogicalPosition, LogicalSize, Webview, WebviewUrl};

/// Height of the chrome bar in logical pixels.
pub const CHROME_BAR_HEIGHT: f64 = 44.0;

/// Creates the chrome bar webview as a child of the given bare window.
/// The webview loads `chrome-bar.html` and is positioned at the top of the window.
pub fn create_chrome_bar(window: &tauri::Window, width: f64) -> Result<Webview, String> {
    window
        .add_child(
            WebviewBuilder::new("chrome-bar", WebviewUrl::App("chrome-bar.html".into())),
            LogicalPosition::new(0.0, 0.0),
            LogicalSize::new(width, CHROME_BAR_HEIGHT),
        )
        .map_err(|e| e.to_string())
}
