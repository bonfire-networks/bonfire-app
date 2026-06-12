//! Layout management for the Bonfire app.
//!
//! On desktop, supports three configurable modes switchable at runtime via the tray menu:
//! - **MultiWindow** (default): separate OS windows for main app and secure chat
//! - **SplitPane**: single window with two webviews side by side
//! - **TabBased**: single window with a chrome bar for tab switching
//!
//! On mobile, only a single WebviewWindow is used (no multi-window/split/tab APIs).

#[cfg(desktop)]
pub mod chrome_bar;
#[cfg(mobile)]
pub mod mobile;
#[cfg(desktop)]
pub mod multi_window;
#[cfg(desktop)]
pub mod split_pane;
#[cfg(desktop)]
pub mod tab_based;

use serde::{Deserialize, Serialize};

use crate::state::Preferences;

// ── Desktop-only imports and helpers ────────────────────────────────

#[cfg(desktop)]
use std::sync::Mutex;
#[cfg(desktop)]
use tauri::webview::WebviewBuilder;
#[cfg(desktop)]
use tauri::{LogicalPosition, LogicalSize, Manager, WebviewUrl};

#[cfg(desktop)]
use multi_window::MultiWindowLayout;
#[cfg(desktop)]
use split_pane::SplitPaneLayout;
#[cfg(desktop)]
use tab_based::TabBasedLayout;

/// Height of the macOS overlay title bar drag region in logical pixels.
#[cfg(desktop)]
pub const TITLE_BAR_HEIGHT: f64 = 8.0;

/// Creates a main-webview builder with `on_navigation` that intercepts
/// custom scheme links (mls://, ap-mls://, bonfire://) and routes them through
/// the deep link handler instead of trying to load them as URLs.
#[cfg(desktop)]
pub fn main_webview_builder(url: &str, app: &tauri::AppHandle) -> WebviewBuilder<tauri::Wry> {
    let app_handle = app.clone();
    let js_debug = crate::JS_DEBUG_MODE.load(std::sync::atomic::Ordering::SeqCst);
    WebviewBuilder::new("main-webview", WebviewUrl::App(url.into()))
        // Clear E2EE client state when the Bonfire web app navigates to /logout.
        // The app-logout event triggers handle_logout in Rust which destroys
        // webviews and recreates the main webview at pick-instance.html.
        // Also sets __BONFIRE_JS_DEBUG__ when an unclean shutdown was detected.
        .initialization_script(&format!(
            r#"
            window.__BONFIRE_JS_DEBUG__ = {js_debug};
            if (window.location.pathname === '/logout' || window.location.pathname.startsWith('/logout')) {{
                console.log('Clearing client state for logout');
                localStorage.clear();
                sessionStorage.clear();
                if (window.__TAURI__) {{
                    window.__TAURI__.event.emit('app-logout');
                }}
            }}
            "#,
        ))
        .on_navigation(move |url| {
            let scheme = url.scheme();
            if scheme == "mls" || scheme == "ap-mls" || scheme == "bonfire" {
                let known = app_handle.state::<Mutex<crate::deep_link::KnownDomains>>();
                let domains = known.lock().ok();
                if let Some(payload) =
                    crate::deep_link::parse_url(&url.to_string(), domains.as_deref())
                {
                    crate::deep_link::handle(&app_handle, &payload);
                }
                false
            } else if scheme == "tauri"
                && url.host_str() == Some("localhost")
                && (url.path() == "/" || url.path().is_empty())
                && url.query().map(|q| q.contains("code=")).unwrap_or(false)
            {
                // OAuth callback lands at tauri://localhost/?code=...&state=...
                // Redirect to pick-instance.html with the same query string so the
                // token exchange can proceed there.
                let query = url.query().unwrap_or("");
                if let Some(wv) = app_handle.get_webview("main-webview") {
                    let _ = wv.eval(&format!(
                        "window.location.replace('pick-instance.html?{query}');"
                    ));
                }
                false
            } else {
                true
            }
        })
}

/// Creates a chat-webview builder with the JS debug flag injected.
#[cfg(desktop)]
pub fn chat_webview_builder() -> WebviewBuilder<tauri::Wry> {
    let js_debug = crate::JS_DEBUG_MODE.load(std::sync::atomic::Ordering::SeqCst);
    WebviewBuilder::new(
        "chat-webview",
        WebviewUrl::App("assets/ap_c2s_client/index.html".into()),
    )
    .initialization_script(&format!("window.__BONFIRE_JS_DEBUG__ = {js_debug};"))
}

/// Destroys all known windows from any layout mode.
#[cfg(desktop)]
pub fn cleanup_all(app: &tauri::AppHandle) {
    if let Some(w) = app.get_window("main-window") {
        let _ = w.destroy();
    }
    if let Some(w) = app.get_window("chat-window") {
        let _ = w.destroy();
    }
    if let Some(w) = app.get_window("unified") {
        let _ = w.destroy();
    }
    if let Some(w) = app.get_webview_window("main") {
        let _ = w.destroy();
    }
    if let Some(w) = app.get_webview_window("secure-chat") {
        let _ = w.destroy();
    }
}

#[cfg(desktop)]
fn close_webview(app: &tauri::AppHandle, label: &str) {
    if let Some(wv) = app.get_webview(label) {
        let _ = wv.close();
    }
}

#[cfg(desktop)]
fn expand_main_webview(app: &tauri::AppHandle) {
    let Some(window) = app.get_window("main-window") else {
        return;
    };
    let Ok(size) = window.inner_size() else {
        return;
    };
    let scale = window.scale_factor().unwrap_or(1.0);
    let w = size.width as f64 / scale;
    let h = size.height as f64 / scale;
    if let Some(wv) = app.get_webview("main-webview") {
        let _ = wv.set_position(LogicalPosition::new(0.0, TITLE_BAR_HEIGHT));
        let _ = wv.set_size(LogicalSize::new(w, h - TITLE_BAR_HEIGHT));
        let _ = wv.show();
    }
}

// ── LayoutMode (all platforms) ──────────────────────────────────────

/// The three supported window layout modes.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum LayoutMode {
    MultiWindow,
    SplitPane,
    TabBased,
}

impl LayoutMode {
    pub fn as_str(&self) -> &'static str {
        match self {
            Self::MultiWindow => "multi-window",
            Self::SplitPane => "split-pane",
            Self::TabBased => "tab-based",
        }
    }

    pub fn from_str(s: &str) -> Option<Self> {
        match s {
            "multi-window" => Some(Self::MultiWindow),
            "split-pane" => Some(Self::SplitPane),
            "tab-based" => Some(Self::TabBased),
            _ => None,
        }
    }

    /// Reads the layout mode from saved preferences.
    /// On mobile, always returns TabBased (multi-window and split-pane are desktop-only).
    pub fn from_preferences(prefs: &Preferences) -> Self {
        #[cfg(mobile)]
        {
            let _ = prefs;
            return Self::TabBased;
        }

        #[cfg(desktop)]
        Self::from_str(&prefs.layout_mode).unwrap_or(Self::MultiWindow)
    }

    pub fn uses_unified(&self) -> bool {
        matches!(self, Self::SplitPane | Self::TabBased)
    }
}

// ── SplitDimensions (all platforms, needed for command return type) ──

/// Return type for split-pane resize commands. Defined here so it's available on all platforms.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SplitDimensions {
    pub window_width: f64,
    pub content_top: f64,
    pub content_height: f64,
}

// ── LayoutManager (desktop) ─────────────────────────────────────────

#[cfg(desktop)]
pub enum LayoutManager {
    MultiWindow(MultiWindowLayout),
    SplitPane(SplitPaneLayout),
    TabBased(TabBasedLayout),
}

#[cfg(desktop)]
impl LayoutManager {
    pub fn new(mode: LayoutMode, prefs: &Preferences) -> Self {
        match mode {
            LayoutMode::MultiWindow => Self::MultiWindow(MultiWindowLayout::new()),
            LayoutMode::SplitPane => Self::SplitPane(SplitPaneLayout::new(prefs)),
            LayoutMode::TabBased => Self::TabBased(TabBasedLayout::new()),
        }
    }

    pub fn mode(&self) -> LayoutMode {
        match self {
            Self::MultiWindow(_) => LayoutMode::MultiWindow,
            Self::SplitPane(_) => LayoutMode::SplitPane,
            Self::TabBased(_) => LayoutMode::TabBased,
        }
    }

    pub fn uses_unified(&self) -> bool {
        self.mode().uses_unified()
    }

    /// Desktop layouts navigate real windows, not URL-based tabs — nothing to store.
    pub fn set_instance_url(&mut self, _url: String) {}

    pub fn setup(
        &mut self,
        app: &tauri::AppHandle,
        url_override: Option<&str>,
    ) -> Result<(), String> {
        match self {
            Self::MultiWindow(l) => l.setup(app, url_override),
            Self::SplitPane(l) => l.setup(app, url_override),
            Self::TabBased(l) => l.setup(app, url_override),
        }
    }

    pub fn teardown(&mut self, app: &tauri::AppHandle) {
        match self {
            Self::MultiWindow(l) => l.teardown(app),
            Self::SplitPane(l) => l.teardown(app),
            Self::TabBased(l) => l.teardown(app),
        }
    }

    pub fn apply_layout(&mut self, app: &tauri::AppHandle) {
        match self {
            Self::SplitPane(l) => l.apply_layout(app),
            Self::TabBased(l) => l.apply_layout(app),
            Self::MultiWindow(_) => {}
        }
    }

    pub fn switch_mode(
        &mut self,
        app: &tauri::AppHandle,
        new_mode: LayoutMode,
        prefs: &Preferences,
    ) -> Result<(), String> {
        if self.mode() == new_mode {
            return Ok(());
        }

        self.save_all_state(app);

        if app.get_window("main-window").is_none() {
            self.teardown(app);
            *self = LayoutManager::new(new_mode, prefs);
            return self.setup(app, None);
        }

        let from_unified = self.uses_unified();
        let to_unified = new_mode.uses_unified();

        match (from_unified, to_unified) {
            (true, true) => {
                *self = LayoutManager::new(new_mode, prefs);
                self.apply_layout(app);
            }
            (true, false) => {
                close_webview(app, "chat-webview");
                close_webview(app, "chrome-bar");
                close_webview(app, "split-divider");
                expand_main_webview(app);
                *self = LayoutManager::new(new_mode, prefs);
                let _ = self.open_chat(app);
            }
            (false, true) => {
                close_webview(app, "chat-webview");
                if let Some(w) = app.get_window("chat-window") {
                    let _ = w.destroy();
                }
                *self = LayoutManager::new(new_mode, prefs);
                self.apply_layout(app);
            }
            (false, false) => {}
        }

        Ok(())
    }

    pub fn open_chat(&mut self, app: &tauri::AppHandle) -> Result<(), String> {
        match self {
            Self::MultiWindow(l) => l.open_chat(app),
            Self::SplitPane(l) => l.open_chat(app),
            Self::TabBased(l) => l.open_chat(app),
        }
    }

    /// Returns true if the chat webview is embedded at startup (tab/split modes).
    /// In multi-window mode the chat window is created on demand.
    pub fn has_chat_webview(&self) -> bool {
        matches!(self, Self::SplitPane(_) | Self::TabBased(_))
    }

    pub fn show_main(&mut self, app: &tauri::AppHandle) {
        match self {
            Self::MultiWindow(l) => l.show_main(app),
            Self::SplitPane(l) => l.show_main(app),
            Self::TabBased(l) => l.show_main(app),
        }
    }

    pub fn switch_tab(&mut self, app: &tauri::AppHandle, tab: &str) -> Result<(), String> {
        match self {
            Self::MultiWindow(l) => l.switch_tab(app, tab),
            Self::SplitPane(l) => l.switch_tab(app, tab),
            Self::TabBased(l) => l.switch_tab(app, tab),
        }
    }

    pub fn active_tab(&self) -> &str {
        match self {
            Self::MultiWindow(l) => l.active_tab(),
            Self::SplitPane(l) => l.active_tab(),
            Self::TabBased(l) => l.active_tab(),
        }
    }

    pub fn save_all_state(&self, app: &tauri::AppHandle) {
        match self {
            Self::MultiWindow(l) => l.save_state(app),
            Self::SplitPane(l) => l.save_state(app),
            Self::TabBased(l) => l.save_state(app),
        }
    }

    pub fn save_window_by_label(&self, app: &tauri::AppHandle, label: &str) {
        match self {
            Self::MultiWindow(l) => l.save_window_by_label(app, label),
            Self::SplitPane(l) => l.save_window_by_label(app, label),
            Self::TabBased(l) => l.save_window_by_label(app, label),
        }
    }

    pub fn handle_resize(&mut self, app: &tauri::AppHandle, label: &str) {
        match self {
            Self::MultiWindow(l) => l.handle_resize(app, label),
            Self::SplitPane(l) => l.handle_resize(app, label),
            Self::TabBased(l) => l.handle_resize(app, label),
        }
    }

    pub fn handle_logout(&mut self, app: &tauri::AppHandle, prefs: &Preferences) {
        self.save_all_state(app);

        close_webview(app, "chat-webview");
        close_webview(app, "chrome-bar");
        close_webview(app, "split-divider");

        if let Some(w) = app.get_window("chat-window") {
            let _ = w.destroy();
        }

        close_webview(app, "main-webview");
        if let Some(window) = app.get_window("main-window") {
            let Ok(size) = window.inner_size() else { return };
            let scale = window.scale_factor().unwrap_or(1.0);
            let w = size.width as f64 / scale;
            let h = size.height as f64 / scale;
            let _ = window.add_child(
                main_webview_builder("pick-instance.html#logout", app),
                LogicalPosition::new(0.0, TITLE_BAR_HEIGHT),
                LogicalSize::new(w, h - TITLE_BAR_HEIGHT),
            );
        }

        let mode = LayoutMode::from_preferences(prefs);
        *self = LayoutManager::new(mode, prefs);
    }
}

// ── LayoutManager (mobile) ──────────────────────────────────────────

/// On mobile, LayoutManager wraps `MobileLayout` which navigates
/// the single WebviewWindow between the Phoenix instance and the
/// local E2EE chat app. Same API surface as the desktop enum.
#[cfg(mobile)]
pub struct LayoutManager(mobile::MobileLayout);

#[cfg(mobile)]
impl LayoutManager {
    pub fn new(_mode: LayoutMode, _prefs: &Preferences) -> Self {
        Self(mobile::MobileLayout::new())
    }

    pub fn set_local_origin(&mut self, origin: String) {
        self.0.set_local_origin(origin);
    }

    pub fn set_instance_url(&mut self, url: String) {
        self.0.set_instance_url(url);
    }

    pub fn mode(&self) -> LayoutMode {
        self.0.mode()
    }

    pub fn setup(
        &mut self,
        app: &tauri::AppHandle,
        url_override: Option<&str>,
    ) -> Result<(), String> {
        self.0.setup(app, url_override)
    }

    pub fn open_chat(&mut self, app: &tauri::AppHandle) -> Result<(), String> {
        self.0.open_chat(app)
    }

    pub fn show_main(&mut self, app: &tauri::AppHandle) {
        self.0.show_main(app)
    }

    pub fn switch_tab(&mut self, app: &tauri::AppHandle, tab: &str) -> Result<(), String> {
        self.0.switch_tab(app, tab)
    }

    pub fn active_tab(&self) -> &str {
        self.0.active_tab()
    }

    pub fn switch_mode(
        &mut self,
        app: &tauri::AppHandle,
        new_mode: LayoutMode,
        prefs: &Preferences,
    ) -> Result<(), String> {
        self.0.switch_mode(app, new_mode, prefs)
    }

    pub fn save_all_state(&self, app: &tauri::AppHandle) {
        self.0.save_all_state(app)
    }
    pub fn save_window_by_label(&self, app: &tauri::AppHandle, label: &str) {
        self.0.save_window_by_label(app, label)
    }
    pub fn handle_resize(&mut self, app: &tauri::AppHandle, label: &str) {
        self.0.handle_resize(app, label)
    }
    pub fn handle_logout(&mut self, app: &tauri::AppHandle, prefs: &Preferences) {
        self.0.handle_logout(app, prefs)
    }
}
