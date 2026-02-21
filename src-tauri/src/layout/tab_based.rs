//! Tab-based layout: single window with a chrome bar for switching between tabs.
//!
//! Both the main app and secure chat webviews exist simultaneously (hidden
//! webviews skip GPU rendering but JS keeps running — good for inbox polling).
//! Only one is visible at a time, controlled by the chrome bar, keyboard
//! shortcuts (Cmd+1/Cmd+2), or tray menu.

use tauri::webview::WebviewBuilder;
use tauri::{Emitter, LogicalPosition, LogicalSize, Manager, WebviewUrl, WindowBuilder};

use crate::layout::chrome_bar::{create_chrome_bar, CHROME_BAR_HEIGHT};
use crate::layout::cleanup_all;
use crate::state::{
    get_geometry, logical_screen_size, save_bare_window_geometry, WindowGeometry,
};

/// Tab-based layout state. Tracks which tab is currently visible.
pub struct TabBasedLayout {
    /// Currently active tab: "main" or "chat".
    active_tab: String,
}

impl TabBasedLayout {
    pub fn new() -> Self {
        Self {
            active_tab: "main".to_string(),
        }
    }

    /// Creates a single bare window ("main-window") with chrome-bar, main-webview,
    /// and chat-webview children. Chat is hidden initially.
    pub fn setup(
        &mut self,
        app: &tauri::AppHandle,
        url_override: Option<&str>,
    ) -> Result<(), String> {
        cleanup_all(app);

        let (sw, sh) = logical_screen_size(app);

        let geom = get_geometry(app, "tab-based", "main-window")
            .or_else(|| get_geometry(app, "tab-based", "unified"))
            .unwrap_or(WindowGeometry {
            x: 0.0,
            y: 0.0,
            width: (sw * 0.75).round(),
            height: sh,
        });

        let main_url = url_override.unwrap_or("pick-instance.html");

        let window = WindowBuilder::new(app, "main-window")
            .title("Bonfire")
            .title_bar_style(tauri::TitleBarStyle::Overlay)
            .hidden_title(true)
            .inner_size(geom.width, geom.height)
            .position(geom.x, geom.y)
            .build()
            .map_err(|e| e.to_string())?;

        create_chrome_bar(&window, geom.width)?;

        let content_h = geom.height - CHROME_BAR_HEIGHT;

        window
            .add_child(
                super::main_webview_builder(main_url, app),
                LogicalPosition::new(0.0, CHROME_BAR_HEIGHT),
                LogicalSize::new(geom.width, content_h),
            )
            .map_err(|e| e.to_string())?;

        let chat_wv = window
            .add_child(
                WebviewBuilder::new(
                    "chat-webview",
                    WebviewUrl::App("assets/ap_c2s_client/index.html".into()),
                ),
                LogicalPosition::new(0.0, CHROME_BAR_HEIGHT),
                LogicalSize::new(geom.width, content_h),
            )
            .map_err(|e| e.to_string())?;

        chat_wv.hide().map_err(|e| e.to_string())?;

        self.active_tab = "main".to_string();
        Ok(())
    }

    /// Applies tab-based layout to an existing unified window.
    /// Lazy-creates chrome-bar if missing, hides split-divider, positions
    /// main/chat webviews full-width with only the active tab visible.
    pub fn apply_layout(&mut self, app: &tauri::AppHandle) {
        let Some(window) = app.get_window("main-window") else {
            return;
        };
        let Ok(size) = window.inner_size() else {
            return;
        };
        let scale = window.scale_factor().unwrap_or(1.0);
        let w = size.width as f64 / scale;
        let h = size.height as f64 / scale;
        let content_h = h - CHROME_BAR_HEIGHT;

        // Ensure chrome-bar exists (may be missing if coming from split-pane without it)
        if app.get_webview("chrome-bar").is_none() {
            let _ = create_chrome_bar(&window, w);
        }
        if let Some(chrome) = app.get_webview("chrome-bar") {
            let _ = chrome.set_position(LogicalPosition::new(0.0, 0.0));
            let _ = chrome.set_size(LogicalSize::new(w, CHROME_BAR_HEIGHT));
            let _ = chrome.show();
        }

        // Hide split-divider if it exists (leftover from split-pane mode)
        if let Some(divider) = app.get_webview("split-divider") {
            let _ = divider.hide();
        }

        // Position both content webviews at full width, show only active tab
        if let Some(main_wv) = app.get_webview("main-webview") {
            let _ = main_wv.set_position(LogicalPosition::new(0.0, CHROME_BAR_HEIGHT));
            let _ = main_wv.set_size(LogicalSize::new(w, content_h));
            if self.active_tab == "main" {
                let _ = main_wv.show();
            } else {
                let _ = main_wv.hide();
            }
        }

        // Ensure chat-webview exists (may not if app started in multi-window mode)
        if app.get_webview("chat-webview").is_none() {
            let _ = window.add_child(
                WebviewBuilder::new(
                    "chat-webview",
                    WebviewUrl::App("assets/ap_c2s_client/index.html".into()),
                ),
                LogicalPosition::new(0.0, CHROME_BAR_HEIGHT),
                LogicalSize::new(w, content_h),
            );
        }

        if let Some(chat_wv) = app.get_webview("chat-webview") {
            let _ = chat_wv.set_position(LogicalPosition::new(0.0, CHROME_BAR_HEIGHT));
            let _ = chat_wv.set_size(LogicalSize::new(w, content_h));
            if self.active_tab == "chat" {
                let _ = chat_wv.show();
            } else {
                let _ = chat_wv.hide();
            }
        }

        // Notify chrome bar of the active tab
        let _ = app.emit("tab-changed", &self.active_tab);
    }

    /// Saves the unified window geometry and destroys it.
    pub fn teardown(&mut self, app: &tauri::AppHandle) {
        if let Some(window) = app.get_window("main-window") {
            save_bare_window_geometry(app, "tab-based:unified", &window);
            let _ = window.destroy();
        }
    }

    /// Switches to the chat tab.
    pub fn open_chat(&mut self, app: &tauri::AppHandle) -> Result<(), String> {
        self.switch_tab(app, "chat")
    }

    /// Switches to the main tab.
    pub fn show_main(&mut self, app: &tauri::AppHandle) {
        let _ = self.switch_tab(app, "main");
    }

    /// Switches the visible tab by showing/hiding the appropriate webview.
    /// Emits a `tab-changed` event so the chrome bar can update its active indicator.
    pub fn switch_tab(
        &mut self,
        app: &tauri::AppHandle,
        tab: &str,
    ) -> Result<(), String> {
        let main_wv = app
            .get_webview("main-webview")
            .ok_or("Main webview not found")?;
        let chat_wv = app
            .get_webview("chat-webview")
            .ok_or("Chat webview not found")?;

        match tab {
            "main" => {
                chat_wv.hide().map_err(|e| e.to_string())?;
                main_wv.show().map_err(|e| e.to_string())?;
                main_wv.set_focus().map_err(|e| e.to_string())?;
            }
            "chat" => {
                main_wv.hide().map_err(|e| e.to_string())?;
                chat_wv.show().map_err(|e| e.to_string())?;
                chat_wv.set_focus().map_err(|e| e.to_string())?;
            }
            _ => return Err(format!("Unknown tab: {}", tab)),
        }

        self.active_tab = tab.to_string();
        let _ = app.emit("tab-changed", tab);

        Ok(())
    }

    /// Returns the name of the currently active tab.
    pub fn active_tab(&self) -> &str {
        &self.active_tab
    }

    /// Persists the unified window's geometry.
    pub fn save_state(&self, app: &tauri::AppHandle) {
        if let Some(window) = app.get_window("main-window") {
            save_bare_window_geometry(app, "tab-based:unified", &window);
        }
    }

    /// Persists geometry for the unified window (only label we manage).
    pub fn save_window_by_label(&self, app: &tauri::AppHandle, label: &str) {
        if label == "main-window" {
            self.save_state(app);
        }
    }

    /// Repositions all child webviews when the unified window is resized.
    pub fn handle_resize(&mut self, app: &tauri::AppHandle, label: &str) {
        if label != "main-window" {
            return;
        }

        let Some(window) = app.get_window("main-window") else {
            return;
        };
        let Ok(size) = window.inner_size() else {
            return;
        };
        let scale = window.scale_factor().unwrap_or(1.0);
        let w = size.width as f64 / scale;
        let h = size.height as f64 / scale;
        let content_h = h - CHROME_BAR_HEIGHT;

        if let Some(chrome) = app.get_webview("chrome-bar") {
            let _ = chrome.set_size(LogicalSize::new(w, CHROME_BAR_HEIGHT));
        }

        if let Some(main_wv) = app.get_webview("main-webview") {
            let _ = main_wv.set_size(LogicalSize::new(w, content_h));
        }
        if let Some(chat_wv) = app.get_webview("chat-webview") {
            let _ = chat_wv.set_size(LogicalSize::new(w, content_h));
        }
    }
}
