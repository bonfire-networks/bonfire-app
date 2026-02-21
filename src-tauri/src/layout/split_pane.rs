//! Split-pane layout: single window with two webviews side by side.
//!
//! Uses the same bare Window + child webview paradigm as the other modes.
//! A draggable divider between panes allows resizing. An optional chrome bar
//! provides a drag region above the split.

use serde::Serialize;
use tauri::webview::WebviewBuilder;
use tauri::{LogicalPosition, LogicalSize, Manager, WebviewUrl, WindowBuilder};

use crate::layout::chrome_bar::{create_chrome_bar, CHROME_BAR_HEIGHT};
use crate::layout::{cleanup_all, TITLE_BAR_HEIGHT};
use crate::state::{
    get_geometry, logical_screen_size, save_bare_window_geometry, Preferences, WindowGeometry,
};

/// Width of the draggable divider between panes in logical pixels.
const DIVIDER_WIDTH: f64 = 6.0;

/// Dimensions returned to the divider JS when a resize drag starts.
#[derive(Serialize)]
pub struct SplitDimensions {
    pub window_width: f64,
    pub content_top: f64,
    pub content_height: f64,
}

/// Split-pane layout state. Tracks the split ratio and chrome bar preference.
pub struct SplitPaneLayout {
    /// Fraction of window width allocated to the main webview (0.0..1.0).
    pub split_ratio: f64,
    /// Whether to show the chrome bar (drag region + title) above the split.
    pub show_chrome_bar: bool,
}

impl SplitPaneLayout {
    pub fn new(prefs: &Preferences) -> Self {
        Self {
            split_ratio: prefs.split_ratio,
            show_chrome_bar: prefs.show_chrome_bar,
        }
    }

    /// The y-offset where content webviews begin (after chrome bar, if shown).
    /// Falls back to TITLE_BAR_HEIGHT so the native drag region stays exposed.
    fn content_top(&self) -> f64 {
        if self.show_chrome_bar {
            CHROME_BAR_HEIGHT
        } else {
            TITLE_BAR_HEIGHT
        }
    }

    /// Creates a single bare window ("main-window") with main-webview, split-divider,
    /// and chat-webview children, plus an optional chrome bar.
    pub fn setup(
        &mut self,
        app: &tauri::AppHandle,
        url_override: Option<&str>,
    ) -> Result<(), String> {
        cleanup_all(app);

        let (sw, sh) = logical_screen_size(app);

        let geom = get_geometry(app, "split-pane", "main-window")
            .or_else(|| get_geometry(app, "split-pane", "unified"))
            .unwrap_or(WindowGeometry {
            x: 0.0,
            y: 0.0,
            width: sw,
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

        if self.show_chrome_bar {
            create_chrome_bar(&window, geom.width)?;
        }

        let top = self.content_top();
        let content_h = geom.height - top;
        let main_w = (geom.width * self.split_ratio).round();
        let chat_w = geom.width - main_w - DIVIDER_WIDTH;

        window
            .add_child(
                super::main_webview_builder(main_url, app),
                LogicalPosition::new(0.0, top),
                LogicalSize::new(main_w, content_h),
            )
            .map_err(|e| e.to_string())?;

        window
            .add_child(
                WebviewBuilder::new(
                    "split-divider",
                    WebviewUrl::App("split-divider.html".into()),
                ),
                LogicalPosition::new(main_w, top),
                LogicalSize::new(DIVIDER_WIDTH, content_h),
            )
            .map_err(|e| e.to_string())?;

        window
            .add_child(
                WebviewBuilder::new(
                    "chat-webview",
                    WebviewUrl::App("assets/ap_c2s_client/index.html".into()),
                ),
                LogicalPosition::new(main_w + DIVIDER_WIDTH, top),
                LogicalSize::new(chat_w, content_h),
            )
            .map_err(|e| e.to_string())?;

        Ok(())
    }

    /// Applies split-pane layout to an existing unified window.
    /// Lazy-creates split-divider if missing, handles chrome-bar visibility,
    /// shows both content webviews side by side.
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
        let top = self.content_top();
        let content_h = h - top;
        let main_w = (w * self.split_ratio).round();
        let chat_w = w - main_w - DIVIDER_WIDTH;

        // Handle chrome-bar: show/hide/create based on preference
        if self.show_chrome_bar {
            if app.get_webview("chrome-bar").is_none() {
                let _ = create_chrome_bar(&window, w);
            }
            if let Some(chrome) = app.get_webview("chrome-bar") {
                let _ = chrome.set_position(LogicalPosition::new(0.0, 0.0));
                let _ = chrome.set_size(LogicalSize::new(w, CHROME_BAR_HEIGHT));
                let _ = chrome.show();
            }
        } else {
            if let Some(chrome) = app.get_webview("chrome-bar") {
                let _ = chrome.hide();
            }
        }

        // Ensure split-divider exists (may be missing if coming from tab-based mode)
        if app.get_webview("split-divider").is_none() {
            let _ = window.add_child(
                WebviewBuilder::new(
                    "split-divider",
                    WebviewUrl::App("split-divider.html".into()),
                ),
                LogicalPosition::new(main_w, top),
                LogicalSize::new(DIVIDER_WIDTH, content_h),
            );
        }

        // Position and show all content webviews
        if let Some(main_wv) = app.get_webview("main-webview") {
            let _ = main_wv.set_position(LogicalPosition::new(0.0, top));
            let _ = main_wv.set_size(LogicalSize::new(main_w, content_h));
            let _ = main_wv.show();
        }

        if let Some(divider) = app.get_webview("split-divider") {
            let _ = divider.set_position(LogicalPosition::new(main_w, top));
            let _ = divider.set_size(LogicalSize::new(DIVIDER_WIDTH, content_h));
            let _ = divider.show();
        }

        // Ensure chat-webview exists (may not if app started in multi-window mode)
        if app.get_webview("chat-webview").is_none() {
            let _ = window.add_child(
                WebviewBuilder::new(
                    "chat-webview",
                    WebviewUrl::App("assets/ap_c2s_client/index.html".into()),
                ),
                LogicalPosition::new(main_w + DIVIDER_WIDTH, top),
                LogicalSize::new(chat_w, content_h),
            );
        }

        if let Some(chat_wv) = app.get_webview("chat-webview") {
            let _ = chat_wv.set_position(LogicalPosition::new(main_w + DIVIDER_WIDTH, top));
            let _ = chat_wv.set_size(LogicalSize::new(chat_w, content_h));
            let _ = chat_wv.show();
        }
    }

    /// Saves the unified window geometry and destroys it.
    pub fn teardown(&mut self, app: &tauri::AppHandle) {
        if let Some(window) = app.get_window("main-window") {
            save_bare_window_geometry(app, "split-pane:unified", &window);
            let _ = window.destroy();
        }
    }

    /// In split-pane mode, chat is always visible. Focus it instead.
    pub fn open_chat(&mut self, app: &tauri::AppHandle) -> Result<(), String> {
        if let Some(chat_wv) = app.get_webview("chat-webview") {
            chat_wv.set_focus().map_err(|e| e.to_string())?;
        }
        Ok(())
    }

    /// Focuses the main webview.
    pub fn show_main(&mut self, app: &tauri::AppHandle) {
        if let Some(main_wv) = app.get_webview("main-webview") {
            let _ = main_wv.set_focus();
        }
    }

    /// Focuses the given pane ("main" or "chat"). Both are always visible
    /// in split-pane mode, so this just moves keyboard focus.
    pub fn switch_tab(&mut self, app: &tauri::AppHandle, tab: &str) -> Result<(), String> {
        match tab {
            "main" => {
                if let Some(wv) = app.get_webview("main-webview") {
                    wv.set_focus().map_err(|e| e.to_string())?;
                }
                Ok(())
            }
            "chat" => self.open_chat(app),
            _ => Err(format!("Unknown tab: {}", tab)),
        }
    }

    /// Returns which pane has focus. Since both are always visible in
    /// split-pane mode, defaults to "main".
    pub fn active_tab(&self) -> &str {
        "main"
    }

    /// Persists the unified window's geometry.
    pub fn save_state(&self, app: &tauri::AppHandle) {
        if let Some(window) = app.get_window("main-window") {
            save_bare_window_geometry(app, "split-pane:unified", &window);
        }
    }

    /// Persists geometry for the unified window (only label we manage).
    pub fn save_window_by_label(&self, app: &tauri::AppHandle, label: &str) {
        if label == "main-window" {
            self.save_state(app);
        }
    }

    /// Called when the divider drag starts. Expands the divider webview to
    /// full window width (transparent overlay) so it can capture all mouse events,
    /// and returns the window dimensions for ratio calculation.
    pub fn resize_start(&self, app: &tauri::AppHandle) -> Result<SplitDimensions, String> {
        let Some(window) = app.get_window("main-window") else {
            return Err("Window not found".into());
        };
        let Ok(size) = window.inner_size() else {
            return Err("Could not get window size".into());
        };
        let scale = window.scale_factor().unwrap_or(1.0);
        let w = size.width as f64 / scale;
        let h = size.height as f64 / scale;
        let top = self.content_top();
        let content_h = h - top;

        // Expand divider to full window width for pointer capture
        if let Some(divider) = app.get_webview("split-divider") {
            let _ = divider.set_position(LogicalPosition::new(0.0, top));
            let _ = divider.set_size(LogicalSize::new(w, content_h));
        }

        Ok(SplitDimensions {
            window_width: w,
            content_top: top,
            content_height: content_h,
        })
    }

    /// Called when the divider drag ends. Updates the split ratio,
    /// repositions all webviews, and shrinks the divider back to its normal width.
    pub fn resize_end(&mut self, app: &tauri::AppHandle, ratio: f64) {
        self.split_ratio = ratio.clamp(0.2, 0.8);
        self.reposition_panes(app);
    }

    /// Repositions all child webviews when the unified window is resized.
    pub fn handle_resize(&mut self, app: &tauri::AppHandle, label: &str) {
        if label != "main-window" {
            return;
        }
        self.reposition_panes(app);
    }

    /// Recalculates and applies positions/sizes for all child webviews
    /// based on the current window size and split ratio.
    fn reposition_panes(&self, app: &tauri::AppHandle) {
        let Some(window) = app.get_window("main-window") else {
            return;
        };
        let Ok(size) = window.inner_size() else {
            return;
        };
        let scale = window.scale_factor().unwrap_or(1.0);
        let w = size.width as f64 / scale;
        let h = size.height as f64 / scale;

        let top = self.content_top();
        let content_h = h - top;
        let main_w = (w * self.split_ratio).round();
        let chat_w = w - main_w - DIVIDER_WIDTH;

        if self.show_chrome_bar {
            if let Some(chrome) = app.get_webview("chrome-bar") {
                let _ = chrome.set_size(LogicalSize::new(w, CHROME_BAR_HEIGHT));
            }
        }

        if let Some(main_wv) = app.get_webview("main-webview") {
            let _ = main_wv.set_position(LogicalPosition::new(0.0, top));
            let _ = main_wv.set_size(LogicalSize::new(main_w, content_h));
        }

        if let Some(divider) = app.get_webview("split-divider") {
            let _ = divider.set_position(LogicalPosition::new(main_w, top));
            let _ = divider.set_size(LogicalSize::new(DIVIDER_WIDTH, content_h));
        }

        if let Some(chat_wv) = app.get_webview("chat-webview") {
            let _ = chat_wv.set_position(LogicalPosition::new(main_w + DIVIDER_WIDTH, top));
            let _ = chat_wv.set_size(LogicalSize::new(chat_w, content_h));
        }
    }
}
