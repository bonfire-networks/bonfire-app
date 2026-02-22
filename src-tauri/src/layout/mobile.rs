//! Mobile layout: single WebviewWindow with URL-based tab navigation.
//!
//! On mobile there's one webview that navigates between the Phoenix instance
//! (home) and the local E2EE chat app. This mirrors the desktop tab-based
//! mode's API (`switch_tab`, `open_chat`, `active_tab`) so commands.rs
//! works unchanged.

use tauri::{Emitter, Manager};

use super::LayoutMode;
use crate::state::Preferences;

pub struct MobileLayout {
    active_tab: String,
    /// URL to return to when switching back to "main" (captured before navigating to chat).
    return_url: Option<String>,
    /// Origin of the local Tauri asset server (e.g. "http://tauri.localhost").
    /// Captured once at startup so we can construct chat URLs from any origin.
    local_origin: String,
}

impl MobileLayout {
    pub fn new() -> Self {
        Self {
            active_tab: "main".to_string(),
            return_url: None,
            local_origin: String::new(),
        }
    }

    /// Store the local asset origin (called once after WebviewWindow is built).
    pub fn set_local_origin(&mut self, origin: String) {
        self.local_origin = origin;
    }

    pub fn mode(&self) -> LayoutMode {
        LayoutMode::TabBased
    }

    pub fn setup(
        &mut self,
        _app: &tauri::AppHandle,
        _url_override: Option<&str>,
    ) -> Result<(), String> {
        Ok(())
    }

    /// Open chat tab — same as desktop `TabBasedLayout::open_chat`.
    /// No-op when called during login flow (pick-instance.html calls open_secure_chat
    /// then immediately navigates to the dashboard itself).
    pub fn open_chat(&mut self, _app: &tauri::AppHandle) -> Result<(), String> {
        // During login, pick-instance.html calls open_secure_chat then navigates
        // to /dashboard. We don't navigate here — the user can reach chat via
        // the bottom nav bar.
        Ok(())
    }

    /// Show the main (home) tab.
    pub fn show_main(&mut self, app: &tauri::AppHandle) {
        let _ = self.switch_tab(app, "main");
    }

    /// Switch the visible tab by navigating the single webview.
    /// Emits `tab-changed` event (same as desktop `TabBasedLayout::switch_tab`).
    pub fn switch_tab(
        &mut self,
        app: &tauri::AppHandle,
        tab: &str,
    ) -> Result<(), String> {
        if tab == self.active_tab {
            return Ok(());
        }

        let ww = app
            .get_webview_window("main")
            .ok_or("WebviewWindow 'main' not found")?;

        match tab {
            "chat" => {
                // Capture current URL so Home returns to exactly this page
                if let Ok(url) = ww.url() {
                    let url_str = url.to_string();
                    if !url_str.contains("pick-instance") && !url_str.contains("ap_c2s_client") {
                        self.return_url = Some(url_str);
                    }
                }
                let chat_url = format!("{}/assets/ap_c2s_client/index.html", self.local_origin);
                let js = format!(
                    "window.location.href = {}",
                    serde_json::to_string(&chat_url).unwrap_or_default()
                );
                ww.eval(&js).map_err(|e| e.to_string())?;
            }
            "main" => {
                if let Some(ref url) = self.return_url {
                    let js = format!(
                        "window.location.href = {}",
                        serde_json::to_string(url).unwrap_or_default()
                    );
                    ww.eval(&js).map_err(|e| e.to_string())?;
                } else {
                    // No saved URL — go to pick-instance which auto-redirects if logged in
                    let url = format!("{}/pick-instance.html", self.local_origin);
                    let js = format!(
                        "window.location.href = {}",
                        serde_json::to_string(&url).unwrap_or_default()
                    );
                    ww.eval(&js).map_err(|e| e.to_string())?;
                }
            }
            _ => return Err(format!("Unknown tab: {tab}")),
        }

        self.active_tab = tab.to_string();
        let _ = app.emit("tab-changed", tab);

        Ok(())
    }

    pub fn active_tab(&self) -> &str {
        &self.active_tab
    }

    pub fn switch_mode(
        &mut self,
        _app: &tauri::AppHandle,
        _new_mode: LayoutMode,
        _prefs: &Preferences,
    ) -> Result<(), String> {
        Err("Layout switching is not available on mobile".into())
    }

    pub fn save_all_state(&self, _app: &tauri::AppHandle) {}
    pub fn save_window_by_label(&self, _app: &tauri::AppHandle, _label: &str) {}
    pub fn handle_resize(&mut self, _app: &tauri::AppHandle, _label: &str) {}

    pub fn handle_logout(&mut self, _app: &tauri::AppHandle, _prefs: &Preferences) {
        self.active_tab = "main".to_string();
        self.return_url = None;
    }
}
