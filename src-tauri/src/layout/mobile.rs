//! Mobile layout: single WebviewWindow with URL-based tab navigation.
//!
//! On mobile there's one webview that navigates between the Phoenix instance
//! (home) and the local E2EE chat app. This mirrors the desktop tab-based
//! mode's API (`switch_tab`, `open_chat`, `active_tab`) so commands.rs
//! works unchanged.

use tauri::{Emitter, Manager};

use super::LayoutMode;
use crate::state::Preferences;

/// URL fragment identifying the local E2EE chat app (also checked by mobile-nav.js).
const CHAT_PATH: &str = "ap_c2s_client";

pub struct MobileLayout {
    active_tab: String,
    /// URL to return to when switching back to "main" (captured before navigating to chat).
    return_url: Option<String>,
    /// Origin of the local Tauri asset server (e.g. "http://tauri.localhost").
    /// Captured once at startup so we can construct chat URLs from any origin.
    local_origin: String,
    /// Base URL of the logged-in instance (e.g. "https://bonfire.cafe"), captured
    /// from `start_notifications`. Lets Home navigate straight to the instance —
    /// going through pick-instance.html would bounce back to chat (its logged-in
    /// path opens the chat tab on mobile).
    instance_url: Option<String>,
}

impl MobileLayout {
    pub fn new() -> Self {
        Self {
            active_tab: "main".to_string(),
            return_url: None,
            local_origin: String::new(),
            instance_url: None,
        }
    }

    /// Store the local asset origin (called once after WebviewWindow is built).
    pub fn set_local_origin(&mut self, origin: String) {
        self.local_origin = origin;
    }

    /// Store the logged-in instance base URL (normalized by `start_notifications`).
    pub fn set_instance_url(&mut self, url: String) {
        self.instance_url = Some(url);
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

    /// Open chat tab by switching to it.
    pub fn open_chat(&mut self, app: &tauri::AppHandle) -> Result<(), String> {
        self.switch_tab(app, "chat")
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
        let ww = app
            .get_webview_window("main")
            .ok_or("WebviewWindow 'main' not found")?;

        // The webview also navigates via plain window.location (the OAuth callback
        // lands on the chat app, post-login goes to the instance), so the cached
        // active_tab can desync from what's on screen — derive it from the URL.
        let current_url = ww.url().map(|u| u.to_string()).unwrap_or_default();
        let current_tab = if current_url.contains(CHAT_PATH) {
            "chat"
        } else {
            "main"
        };

        if tab == current_tab {
            self.active_tab = current_tab.to_string();
            return Ok(());
        }

        let dest = match tab {
            "chat" => {
                // Capture current URL so Home returns to exactly this page
                if !current_url.is_empty() && !current_url.contains("pick-instance") {
                    self.return_url = Some(current_url.clone());
                }
                format!("{}/assets/{}/index.html", self.local_origin, CHAT_PATH)
            }
            // Priority: page we left from > instance dashboard > login screen.
            // Never fall back to pick-instance while logged in: its logged-in
            // path re-opens the chat tab on mobile, looping back here.
            "main" => self
                .return_url
                .clone()
                .or_else(|| {
                    self.instance_url
                        .as_ref()
                        .map(|base| format!("{base}/dashboard"))
                })
                .unwrap_or_else(|| format!("{}/pick-instance.html", self.local_origin)),
            _ => return Err(format!("Unknown tab: {tab}")),
        };
        let js = format!(
            "window.location.href = {}",
            serde_json::to_string(&dest).unwrap_or_default()
        );
        ww.eval(&js).map_err(|e| e.to_string())?;

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
        self.instance_url = None;
    }
}
