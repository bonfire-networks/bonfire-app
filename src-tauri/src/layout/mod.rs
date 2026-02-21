//! Layout management for the Bonfire desktop app.
//!
//! Supports three configurable modes switchable at runtime via the tray menu:
//! - **MultiWindow** (default): separate OS windows for main app and secure chat
//! - **SplitPane**: single window with two webviews side by side
//! - **TabBased**: single window with a chrome bar for tab switching
//!
//! All modes use bare `Window` + `add_child` for consistency. A single
//! "main-window" persists across all mode switches — only child webviews are
//! added/removed/repositioned. Multi-window mode adds a second "chat-window"
//! for the standalone chat; unified modes (split/tab) keep chat as a child
//! of main-window.

pub mod chrome_bar;
pub mod multi_window;
pub mod split_pane;
pub mod tab_based;

use std::sync::Mutex;

use serde::{Deserialize, Serialize};
use tauri::webview::WebviewBuilder;
use tauri::{LogicalPosition, LogicalSize, Manager, WebviewUrl};

use crate::state::Preferences;

/// Creates a main-webview builder with `on_navigation` that intercepts
/// custom scheme links (mls://, ap-mls://, bonfire://) and routes them through
/// the deep link handler instead of trying to load them as URLs.
pub fn main_webview_builder(url: &str, app: &tauri::AppHandle) -> WebviewBuilder<tauri::Wry> {
    let app_handle = app.clone();
    WebviewBuilder::new("main-webview", WebviewUrl::App(url.into())).on_navigation(move |url| {
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
        } else {
            true
        }
    })
}

/// Height of the macOS overlay title bar drag region in logical pixels.
/// In multi-window mode (no chrome bar), webviews start below this offset
/// so the native title bar drag region remains exposed and clickable.
pub const TITLE_BAR_HEIGHT: f64 = 8.0;
use multi_window::MultiWindowLayout;
use split_pane::SplitPaneLayout;
use tab_based::TabBasedLayout;

/// Destroys all known windows from any layout mode.
/// Safety net called during `setup()` for fresh starts (app launch, logout).
pub fn cleanup_all(app: &tauri::AppHandle) {
    if let Some(w) = app.get_window("main-window") {
        let _ = w.destroy();
    }
    if let Some(w) = app.get_window("chat-window") {
        let _ = w.destroy();
    }
    // Legacy labels from before the unified paradigm
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

/// Closes a child webview by label, removing it from its parent window.
/// `Webview::close()` frees the label synchronously from Tauri's internal
/// registry, so a new webview with the same label can be created immediately.
fn close_webview(app: &tauri::AppHandle, label: &str) {
    if let Some(wv) = app.get_webview(label) {
        let _ = wv.close();
    }
}

/// Expands main-webview to fill the main-window below the title bar
/// (used when transitioning to multi-window mode where there are no other children).
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

/// The three supported window layout modes.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum LayoutMode {
    MultiWindow,
    SplitPane,
    TabBased,
}

impl LayoutMode {
    /// Returns the string identifier used in preferences and tray menu IDs.
    pub fn as_str(&self) -> &'static str {
        match self {
            Self::MultiWindow => "multi-window",
            Self::SplitPane => "split-pane",
            Self::TabBased => "tab-based",
        }
    }

    /// Parses a mode string back into a LayoutMode variant.
    pub fn from_str(s: &str) -> Option<Self> {
        match s {
            "multi-window" => Some(Self::MultiWindow),
            "split-pane" => Some(Self::SplitPane),
            "tab-based" => Some(Self::TabBased),
            _ => None,
        }
    }

    /// Reads the layout mode from saved preferences, defaulting to MultiWindow.
    pub fn from_preferences(prefs: &Preferences) -> Self {
        Self::from_str(&prefs.layout_mode).unwrap_or(Self::MultiWindow)
    }

    /// Whether this mode uses the shared single-window layout (split or tab).
    pub fn uses_unified(&self) -> bool {
        matches!(self, Self::SplitPane | Self::TabBased)
    }
}

/// Dispatch enum that delegates layout operations to the active mode's implementation.
/// Stored in managed Tauri state behind a `Mutex`.
pub enum LayoutManager {
    MultiWindow(MultiWindowLayout),
    SplitPane(SplitPaneLayout),
    TabBased(TabBasedLayout),
}

impl LayoutManager {
    /// Creates a new layout manager for the given mode and preferences.
    pub fn new(mode: LayoutMode, prefs: &Preferences) -> Self {
        match mode {
            LayoutMode::MultiWindow => Self::MultiWindow(MultiWindowLayout::new()),
            LayoutMode::SplitPane => Self::SplitPane(SplitPaneLayout::new(prefs)),
            LayoutMode::TabBased => Self::TabBased(TabBasedLayout::new()),
        }
    }

    /// Returns the current layout mode.
    pub fn mode(&self) -> LayoutMode {
        match self {
            Self::MultiWindow(_) => LayoutMode::MultiWindow,
            Self::SplitPane(_) => LayoutMode::SplitPane,
            Self::TabBased(_) => LayoutMode::TabBased,
        }
    }

    /// Whether this layout uses the shared single-window layout.
    pub fn uses_unified(&self) -> bool {
        self.mode().uses_unified()
    }

    /// Creates the initial windows/webviews for this layout from scratch.
    /// Only used for fresh starts (app launch, logout). For runtime mode
    /// switches, use `switch_mode()` instead.
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

    /// Saves window state and destroys all windows/webviews.
    /// Used for logout (clean slate). For mode switching use `switch_mode()`.
    pub fn teardown(&mut self, app: &tauri::AppHandle) {
        match self {
            Self::MultiWindow(l) => l.teardown(app),
            Self::SplitPane(l) => l.teardown(app),
            Self::TabBased(l) => l.teardown(app),
        }
    }

    /// Applies the current mode's layout to the existing main-window.
    /// Lazy-creates any mode-specific webviews, repositions/shows/hides children.
    /// No-op for multi-window mode.
    pub fn apply_layout(&mut self, app: &tauri::AppHandle) {
        match self {
            Self::SplitPane(l) => l.apply_layout(app),
            Self::TabBased(l) => l.apply_layout(app),
            Self::MultiWindow(_) => {}
        }
    }

    /// Switches to a new layout mode at runtime.
    ///
    /// The main-window is never destroyed — only child webviews are
    /// added/removed/repositioned:
    /// - **Unified ↔ Unified** (split ↔ tab): reposition/show/hide children.
    /// - **Unified → Multi-window**: close chat/chrome/divider children,
    ///   expand main-webview. Chat window created on demand.
    /// - **Multi-window → Unified**: destroy chat-window, add chat-webview
    ///   back to main-window, apply layout.
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

        // If no main-window exists, fall back to a fresh setup
        if app.get_window("main-window").is_none() {
            self.teardown(app);
            *self = LayoutManager::new(new_mode, prefs);
            return self.setup(app, None);
        }

        let from_unified = self.uses_unified();
        let to_unified = new_mode.uses_unified();

        match (from_unified, to_unified) {
            (true, true) => {
                // Unified ↔ Unified: apply_layout handles show/hide/create
                *self = LayoutManager::new(new_mode, prefs);
                self.apply_layout(app);
            }
            (true, false) => {
                // Unified → Multi-window: close unified children (frees labels),
                // then open chat in a separate window with the same label.
                close_webview(app, "chat-webview");
                close_webview(app, "chrome-bar");
                close_webview(app, "split-divider");
                expand_main_webview(app);
                *self = LayoutManager::new(new_mode, prefs);
                // Open chat immediately in a separate window
                let _ = self.open_chat(app);
            }
            (false, true) => {
                // Multi-window → Unified: close standalone chat-webview
                // (frees label), destroy chat-window, then add chat-webview
                // to main-window via apply_layout's lazy creation.
                close_webview(app, "chat-webview");
                if let Some(w) = app.get_window("chat-window") {
                    let _ = w.destroy();
                }
                *self = LayoutManager::new(new_mode, prefs);
                self.apply_layout(app);
            }
            (false, false) => {
                // Multi-window → Multi-window: no-op (same topology)
            }
        }

        Ok(())
    }

    /// Opens or focuses the secure chat.
    pub fn open_chat(&mut self, app: &tauri::AppHandle) -> Result<(), String> {
        match self {
            Self::MultiWindow(l) => l.open_chat(app),
            Self::SplitPane(l) => l.open_chat(app),
            Self::TabBased(l) => l.open_chat(app),
        }
    }

    /// Shows or focuses the main window/webview.
    pub fn show_main(&mut self, app: &tauri::AppHandle) {
        match self {
            Self::MultiWindow(l) => l.show_main(app),
            Self::SplitPane(l) => l.show_main(app),
            Self::TabBased(l) => l.show_main(app),
        }
    }

    /// Switches focus to the given view ("main" or "chat").
    pub fn switch_tab(&mut self, app: &tauri::AppHandle, tab: &str) -> Result<(), String> {
        match self {
            Self::MultiWindow(l) => l.switch_tab(app, tab),
            Self::SplitPane(l) => l.switch_tab(app, tab),
            Self::TabBased(l) => l.switch_tab(app, tab),
        }
    }

    /// Returns the name of the currently focused view ("main" or "chat").
    pub fn active_tab(&self) -> &str {
        match self {
            Self::MultiWindow(l) => l.active_tab(),
            Self::SplitPane(l) => l.active_tab(),
            Self::TabBased(l) => l.active_tab(),
        }
    }

    /// Persists geometry for all windows managed by this layout.
    pub fn save_all_state(&self, app: &tauri::AppHandle) {
        match self {
            Self::MultiWindow(l) => l.save_state(app),
            Self::SplitPane(l) => l.save_state(app),
            Self::TabBased(l) => l.save_state(app),
        }
    }

    /// Persists geometry for a specific window by its label.
    pub fn save_window_by_label(&self, app: &tauri::AppHandle, label: &str) {
        match self {
            Self::MultiWindow(l) => l.save_window_by_label(app, label),
            Self::SplitPane(l) => l.save_window_by_label(app, label),
            Self::TabBased(l) => l.save_window_by_label(app, label),
        }
    }

    /// Handles window resize events.
    pub fn handle_resize(&mut self, app: &tauri::AppHandle, label: &str) {
        match self {
            Self::MultiWindow(l) => l.handle_resize(app, label),
            Self::SplitPane(l) => l.handle_resize(app, label),
            Self::TabBased(l) => l.handle_resize(app, label),
        }
    }

    /// Handles logout by navigating the existing main-webview to the logout
    /// page instead of destroying/recreating windows (which races with async
    /// window destruction). Cleans up extra webviews/windows and resets to
    /// a single main-window with main-webview.
    pub fn handle_logout(&mut self, app: &tauri::AppHandle, prefs: &Preferences) {
        self.save_all_state(app);

        // Close extra child webviews (synchronous label freeing)
        close_webview(app, "chat-webview");
        close_webview(app, "chrome-bar");
        close_webview(app, "split-divider");

        // Destroy standalone chat window if in multi-window mode
        if let Some(w) = app.get_window("chat-window") {
            let _ = w.destroy();
        }

        // Close main-webview (frees label synchronously) and recreate it
        // pointed at the logout page. More reliable than eval/navigate.
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

        // Reset layout manager to current preferred mode (clean state)
        let mode = LayoutMode::from_preferences(prefs);
        *self = LayoutManager::new(mode, prefs);
    }
}
