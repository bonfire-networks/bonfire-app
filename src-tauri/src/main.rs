// Prevents additional console window on Windows in release, DO NOT REMOVE!!
#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]

mod layout;
mod notifications;
mod state;

use std::sync::Mutex;

use layout::{LayoutManager, LayoutMode};
use notifications::NotificationListener;
use state::{load_preferences, save_preferences, Preferences};
use tauri::{
    menu::{Menu, MenuItem, PredefinedMenuItem},
    tray::TrayIconBuilder,
    Listener, Manager, RunEvent,
};

/// Application state managed by Tauri, protected by a Mutex for thread safety.
/// Contains the active layout manager and user preferences.
pub struct AppState {
    pub layout_manager: LayoutManager,
    pub preferences: Preferences,
    pub notification_listener: Option<NotificationListener>,
}

// ── Tauri commands ──────────────────────────────────────────────────────────

/// Opens the secure chat window/webview. Delegates to the active layout manager.
/// Called from pick-instance.html after successful login.
#[tauri::command]
async fn open_secure_chat(
    app: tauri::AppHandle,
    app_state: tauri::State<'_, Mutex<AppState>>,
) -> Result<(), String> {
    let mut state = app_state.lock().map_err(|e| e.to_string())?;
    state.layout_manager.open_chat(&app)
}

/// Returns the current layout mode as a string ("multi-window", "split-pane", "tab-based").
#[tauri::command]
async fn get_layout_mode(
    app_state: tauri::State<'_, Mutex<AppState>>,
) -> Result<String, String> {
    let state = app_state.lock().map_err(|e| e.to_string())?;
    Ok(state.layout_manager.mode().as_str().to_string())
}

/// Switches the layout mode at runtime. Reuses the unified window when
/// switching between split-pane and tab-based; does a full teardown/setup
/// for transitions to/from multi-window.
#[tauri::command]
async fn set_layout_mode(
    app: tauri::AppHandle,
    app_state: tauri::State<'_, Mutex<AppState>>,
    mode: String,
) -> Result<(), String> {
    let new_mode = LayoutMode::from_str(&mode).ok_or("Invalid layout mode")?;

    let mut state = app_state.lock().map_err(|e| e.to_string())?;

    // Update preferences
    state.preferences.layout_mode = mode;
    save_preferences(&app, &state.preferences);

    // Clone to satisfy borrow checker (switch_mode borrows layout_manager mutably)
    let prefs = state.preferences.clone();
    state.layout_manager.switch_mode(&app, new_mode, &prefs)
}

/// Switches the active tab (tab-based mode only). No-op in other modes.
#[tauri::command]
async fn switch_tab(
    app: tauri::AppHandle,
    app_state: tauri::State<'_, Mutex<AppState>>,
    tab: String,
) -> Result<(), String> {
    let mut state = app_state.lock().map_err(|e| e.to_string())?;
    state.layout_manager.switch_tab(&app, &tab)
}

/// Returns the currently active tab name ("main" or "chat").
#[tauri::command]
async fn get_active_tab(
    app_state: tauri::State<'_, Mutex<AppState>>,
) -> Result<String, String> {
    let state = app_state.lock().map_err(|e| e.to_string())?;
    Ok(state.layout_manager.active_tab().to_string())
}

/// Begins a split-pane resize drag. Expands the divider webview to full
/// window width and returns the window dimensions for ratio calculation.
#[tauri::command]
async fn split_resize_start(
    app: tauri::AppHandle,
    app_state: tauri::State<'_, Mutex<AppState>>,
) -> Result<layout::split_pane::SplitDimensions, String> {
    let state = app_state.lock().map_err(|e| e.to_string())?;
    match &state.layout_manager {
        LayoutManager::SplitPane(l) => l.resize_start(&app),
        _ => Err("Not in split-pane mode".into()),
    }
}

/// Ends a split-pane resize drag. Updates the split ratio, repositions all
/// panes, and saves the new ratio to preferences.
#[tauri::command]
async fn split_resize_end(
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

/// Starts the SSE notification listener. Called from JS after login with
/// the instance URL and OAuth access token.
#[tauri::command]
async fn start_notifications(
    app: tauri::AppHandle,
    app_state: tauri::State<'_, Mutex<AppState>>,
    instance_url: String,
    token: String,
) -> Result<(), String> {
    let mut state = app_state.lock().map_err(|e| e.to_string())?;

    // Stop any existing listener before starting a new one
    if let Some(listener) = state.notification_listener.take() {
        listener.stop();
    }

    state.notification_listener =
        Some(NotificationListener::start(app.clone(), instance_url, token));
    Ok(())
}

/// Stops the SSE notification listener. Called on logout.
#[tauri::command]
async fn stop_notifications(
    app_state: tauri::State<'_, Mutex<AppState>>,
) -> Result<(), String> {
    let mut state = app_state.lock().map_err(|e| e.to_string())?;
    if let Some(listener) = state.notification_listener.take() {
        listener.stop();
    }
    Ok(())
}

// ── Tray menu ───────────────────────────────────────────────────────────────

/// Builds the system tray menu with layout mode selection.
fn build_tray_menu(app: &tauri::App, current_mode: LayoutMode) -> Result<Menu<tauri::Wry>, Box<dyn std::error::Error>> {
    let show_i = MenuItem::with_id(app, "show", "Show Bonfire", true, None::<&str>)?;
    let messages_i = MenuItem::with_id(app, "messages", "Messages", true, None::<&str>)?;
    let separator1 = PredefinedMenuItem::separator(app)?;

    // Layout mode radio items (prefix current mode with a bullet)
    let mw_label = format!(
        "{} Multi-window",
        if current_mode == LayoutMode::MultiWindow { "\u{2022}" } else { "  " }
    );
    let sp_label = format!(
        "{} Split-pane",
        if current_mode == LayoutMode::SplitPane { "\u{2022}" } else { "  " }
    );
    let tb_label = format!(
        "{} Tab-based",
        if current_mode == LayoutMode::TabBased { "\u{2022}" } else { "  " }
    );

    let mw_i = MenuItem::with_id(app, "layout-multi-window", &mw_label, true, None::<&str>)?;
    let sp_i = MenuItem::with_id(app, "layout-split-pane", &sp_label, true, None::<&str>)?;
    let tb_i = MenuItem::with_id(app, "layout-tab-based", &tb_label, true, None::<&str>)?;

    let separator2 = PredefinedMenuItem::separator(app)?;
    let logout_i = MenuItem::with_id(app, "logout", "Log out", true, None::<&str>)?;
    let quit_i = MenuItem::with_id(app, "quit", "Quit", true, None::<&str>)?;

    Menu::with_items(
        app,
        &[
            &show_i,
            &messages_i,
            &separator1,
            &mw_i,
            &sp_i,
            &tb_i,
            &separator2,
            &logout_i,
            &quit_i,
        ],
    )
    .map_err(Into::into)
}

// ── Logout ──────────────────────────────────────────────────────────────────

/// Handles logout: navigates main-webview to the logout page and cleans up
/// extra webviews/windows without destroying the main-window.
fn logout(app: &tauri::AppHandle) {
    let state_mutex = app.state::<Mutex<AppState>>();
    let mut state = match state_mutex.lock() {
        Ok(s) => s,
        Err(_) => return,
    };

    // Stop SSE notification listener
    if let Some(listener) = state.notification_listener.take() {
        listener.stop();
    }

    let prefs = state.preferences.clone();
    state.layout_manager.handle_logout(app, &prefs);
}

/// Shows the messages/secure-chat window. Creates it if it doesn't exist.
fn show_messages_window(app: &tauri::AppHandle) {
    let state_mutex = app.state::<Mutex<AppState>>();
    let mut state = match state_mutex.lock() {
        Ok(s) => s,
        Err(_) => return,
    };

    let _ = state.layout_manager.open_chat(app);
}

// ── Entry point ─────────────────────────────────────────────────────────────

fn main() {
    // Load preferences to determine initial layout mode
    let prefs_for_setup = std::sync::Arc::new(Mutex::new(None::<Preferences>));
    let prefs_clone = prefs_for_setup.clone();

    let app = tauri::Builder::default()
        .plugin(tauri_plugin_openmls::init())
        .plugin(tauri_plugin_notification::init())
        .invoke_handler(tauri::generate_handler![
            open_secure_chat,
            get_layout_mode,
            set_layout_mode,
            switch_tab,
            get_active_tab,
            split_resize_start,
            split_resize_end,
            start_notifications,
            stop_notifications,
        ])
        .setup(move |app| {
            // Load preferences and determine layout mode
            let prefs = load_preferences(app.handle());
            let mode = LayoutMode::from_preferences(&prefs);

            // Create and setup layout manager
            let mut layout_manager = LayoutManager::new(mode, &prefs);
            if let Err(e) = layout_manager.setup(
                app.handle(),
                Some("pick-instance.html"),
            ) {
                eprintln!("Layout setup failed: {}", e);
            }

            // Register managed state
            app.manage(Mutex::new(AppState {
                layout_manager,
                preferences: prefs.clone(),
                notification_listener: None,
            }));

            // Store prefs for tray menu construction
            if let Ok(mut p) = prefs_clone.lock() {
                *p = Some(prefs);
            }

            // Build tray menu
            let menu = build_tray_menu(app, mode)?;

            let _tray = TrayIconBuilder::new()
                .icon(app.default_window_icon().unwrap().clone())
                .menu(&menu)
                .show_menu_on_left_click(true)
                .on_menu_event(|app, event| match event.id.as_ref() {
                    "show" => {
                        let state_mutex = app.state::<Mutex<AppState>>();
                        let Ok(mut state) = state_mutex.lock() else { return };
                        state.layout_manager.show_main(app);
                    }
                    "messages" => show_messages_window(app),
                    "logout" => logout(app),
                    "quit" => app.exit(0),
                    id if id.starts_with("layout-") => {
                        let mode_str = id.strip_prefix("layout-").unwrap_or("");
                        let Some(new_mode) = LayoutMode::from_str(mode_str) else { return };
                        let state_mutex = app.state::<Mutex<AppState>>();
                        let Ok(mut state) = state_mutex.lock() else { return };
                        state.preferences.layout_mode = mode_str.to_string();
                        save_preferences(app, &state.preferences);
                        let prefs = state.preferences.clone();
                        if let Err(e) = state.layout_manager.switch_mode(app, new_mode, &prefs) {
                            eprintln!("Layout switch failed: {}", e);
                        }
                    }
                    _ => {}
                })
                .build(app)?;

            // Listen for logout event from the frontend
            let handle = app.handle().clone();
            app.listen("app-logout", move |_event| {
                logout(&handle);
            });

            Ok(())
        })
        .build(tauri::generate_context!())
        .expect("Error while building Bonfire desktop app");

    // Keep the app alive when all windows are closed (tray stays active)
    app.run(|app, event| match event {
        RunEvent::ExitRequested { code, api, .. } => {
            // Only prevent exit when triggered by last window closing (code == None),
            // not when explicitly requested via app.exit() (code == Some)
            if code.is_none() {
                api.prevent_exit();
            }
        }
        RunEvent::WindowEvent {
            label,
            event: tauri::WindowEvent::CloseRequested { .. },
            ..
        } => {
            let state_mutex = app.state::<Mutex<AppState>>();
            let Ok(state) = state_mutex.lock() else { return };
            state.layout_manager.save_window_by_label(app, &label);
        }
        // Reposition child webviews on resize (single-window modes)
        RunEvent::WindowEvent {
            label,
            event: tauri::WindowEvent::Resized(_),
            ..
        } => {
            let state_mutex = app.state::<Mutex<AppState>>();
            let Ok(mut state) = state_mutex.lock() else { return };
            state.layout_manager.handle_resize(app, &label);
        }
        _ => {}
    });
}
