//! Multi-window layout: separate OS windows for the main app and secure chat.
//!
//! Each window is a bare `Window` with a single child webview, using the same
//! paradigm as the other modes for consistency. Windows have native decorations
//! via `TitleBarStyle::Overlay` with hidden title.
//!
//! This is the default layout mode.

use tauri::webview::WebviewBuilder;
use tauri::{LogicalPosition, LogicalSize, Manager, WebviewUrl, WindowBuilder};

use crate::layout::{cleanup_all, TITLE_BAR_HEIGHT};
use crate::state::{
    get_geometry, load_state, logical_screen_size, save_bare_window_geometry, WindowGeometry,
};

/// Multi-window layout state. Stateless since each window is independent.
pub struct MultiWindowLayout;

impl MultiWindowLayout {
    pub fn new() -> Self {
        Self
    }

    /// Creates the main window at the pick-instance page (or a custom URL).
    pub fn setup(
        &mut self,
        app: &tauri::AppHandle,
        url_override: Option<&str>,
    ) -> Result<(), String> {
        cleanup_all(app);

        let url = url_override.unwrap_or("pick-instance.html");
        self.ensure_main_window(app, url)
    }

    /// Saves geometry for both windows and destroys them.
    pub fn teardown(&mut self, app: &tauri::AppHandle) {
        if let Some(window) = app.get_window("chat-window") {
            save_bare_window_geometry(app, "multi-window:chat-window", &window);
            let _ = window.destroy();
        }
        if let Some(window) = app.get_window("main-window") {
            save_bare_window_geometry(app, "multi-window:main-window", &window);
            let _ = window.destroy();
        }
    }

    /// Opens the secure chat in a separate window beside the main window.
    /// If the chat window already exists, focuses it instead.
    /// On first open (no saved state), auto-sizes both windows to fill the screen.
    pub fn open_chat(&mut self, app: &tauri::AppHandle) -> Result<(), String> {
        // Focus existing chat window
        if let Some(window) = app.get_window("chat-window") {
            window.set_focus().map_err(|e| e.to_string())?;
            return Ok(());
        }

        let (sw, sh) = logical_screen_size(app);
        let main_w = (sw * 2.0 / 2.9).round();
        let chat_w = sw - main_w;

        let geom = get_geometry(app, "multi-window", "chat-window")
            .or_else(|| get_geometry(app, "multi-window", "secure-chat"))
            .unwrap_or(WindowGeometry {
                x: main_w,
                y: 0.0,
                width: chat_w,
                height: sh,
            });

        let window = WindowBuilder::new(app, "chat-window")
            .title("Secure Chat")
            .title_bar_style(tauri::TitleBarStyle::Overlay)
            .hidden_title(true)
            .inner_size(geom.width, geom.height)
            .position(geom.x, geom.y)
            .build()
            .map_err(|e| e.to_string())?;

        window
            .add_child(
                WebviewBuilder::new(
                    "chat-webview",
                    WebviewUrl::App("assets/ap_c2s_client/index.html".into()),
                ),
                LogicalPosition::new(0.0, TITLE_BAR_HEIGHT),
                LogicalSize::new(geom.width, geom.height - TITLE_BAR_HEIGHT),
            )
            .map_err(|e| e.to_string())?;

        // Auto-tile: resize main window to fit beside chat if using default layout
        let state = load_state(app);
        if state.get("multi-window:main-window").is_none()
            && state.get("multi-window:main").is_none()
            && state.get("main").is_none()
        {
            if let Some(main_win) = app.get_window("main-window") {
                let _ = main_win.set_size(LogicalSize::new(main_w, sh));
                let _ = main_win.set_position(LogicalPosition::new(0.0, 0.0));
                if let Some(main_wv) = app.get_webview("main-webview") {
                    let _ = main_wv.set_size(LogicalSize::new(main_w, sh - TITLE_BAR_HEIGHT));
                }
            }
        }

        Ok(())
    }

    /// Shows or creates the main window.
    pub fn show_main(&mut self, app: &tauri::AppHandle) {
        if let Some(window) = app.get_window("main-window") {
            let _ = window.show();
            let _ = window.set_focus();
            return;
        }
        let _ = self.ensure_main_window(app, "pick-instance.html");
    }

    /// Focuses the given view's window ("main" or "chat").
    /// For "chat", opens the secure-chat window if it doesn't exist.
    pub fn switch_tab(&mut self, app: &tauri::AppHandle, tab: &str) -> Result<(), String> {
        match tab {
            "main" => {
                if let Some(window) = app.get_window("main-window") {
                    window.set_focus().map_err(|e| e.to_string())?;
                }
                Ok(())
            }
            "chat" => self.open_chat(app),
            _ => Err(format!("Unknown tab: {}", tab)),
        }
    }

    /// Returns which window is currently focused (defaults to "main").
    pub fn active_tab(&self) -> &str {
        "main"
    }

    /// Persists geometry for all managed windows.
    pub fn save_state(&self, app: &tauri::AppHandle) {
        if let Some(window) = app.get_window("main-window") {
            save_bare_window_geometry(app, "multi-window:main-window", &window);
        }
        if let Some(window) = app.get_window("chat-window") {
            save_bare_window_geometry(app, "multi-window:chat-window", &window);
        }
    }

    /// Persists geometry for a single window by its label.
    pub fn save_window_by_label(&self, app: &tauri::AppHandle, label: &str) {
        if let Some(window) = app.get_window(label) {
            save_bare_window_geometry(app, &format!("multi-window:{}", label), &window);
        }
    }

    /// Resizes the child webview to fill the parent window on resize.
    pub fn handle_resize(&mut self, app: &tauri::AppHandle, label: &str) {
        let webview_label = match label {
            "main-window" => "main-webview",
            "chat-window" => "chat-webview",
            _ => return,
        };

        let Some(window) = app.get_window(label) else {
            return;
        };
        let Ok(size) = window.inner_size() else {
            return;
        };
        let scale = window.scale_factor().unwrap_or(1.0);
        let w = size.width as f64 / scale;
        let h = size.height as f64 / scale;

        if let Some(wv) = app.get_webview(webview_label) {
            let _ = wv.set_size(LogicalSize::new(w, h - TITLE_BAR_HEIGHT));
        }
    }

    /// Creates the main window with the given URL if it doesn't exist.
    fn ensure_main_window(&self, app: &tauri::AppHandle, url: &str) -> Result<(), String> {
        if let Some(window) = app.get_window("main-window") {
            let _ = window.show();
            let _ = window.set_focus();
            return Ok(());
        }

        let (sw, sh) = logical_screen_size(app);
        let default_w = (sw * 2.0 / 2.9).round();

        let geom = get_geometry(app, "multi-window", "main-window")
            .or_else(|| get_geometry(app, "multi-window", "main"))
            .unwrap_or(WindowGeometry {
                x: 0.0,
                y: 0.0,
                width: default_w,
                height: sh,
            });

        let window = WindowBuilder::new(app, "main-window")
            .title("Bonfire")
            .title_bar_style(tauri::TitleBarStyle::Overlay)
            .hidden_title(true)
            .position(geom.x, geom.y)
            .inner_size(geom.width, geom.height)
            .build()
            .map_err(|e| e.to_string())?;

        window
            .add_child(
                super::main_webview_builder(url, app),
                LogicalPosition::new(0.0, TITLE_BAR_HEIGHT),
                LogicalSize::new(geom.width, geom.height - TITLE_BAR_HEIGHT),
            )
            .map_err(|e| e.to_string())?;

        Ok(())
    }
}
