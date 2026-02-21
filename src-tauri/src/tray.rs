use std::sync::Mutex;

use tauri::menu::{Menu, MenuItem, PredefinedMenuItem};
use tauri::tray::TrayIconBuilder;
use tauri::{Listener, Manager};

use crate::layout::LayoutMode;
use crate::state::save_preferences;
use crate::AppState;

/// Handles logout: navigates main-webview to the logout page and cleans up
/// extra webviews/windows without destroying the main-window.
pub fn logout(app: &tauri::AppHandle) {
    let state_mutex = app.state::<Mutex<AppState>>();
    let mut state = match state_mutex.lock() {
        Ok(s) => s,
        Err(_) => return,
    };

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

/// Builds the system tray menu with layout mode selection.
fn build_menu(
    app: &tauri::App,
    current_mode: LayoutMode,
) -> Result<Menu<tauri::Wry>, Box<dyn std::error::Error>> {
    let show_i = MenuItem::with_id(app, "show", "Show Bonfire", true, None::<&str>)?;
    let messages_i = MenuItem::with_id(app, "messages", "Messages", true, None::<&str>)?;
    let separator1 = PredefinedMenuItem::separator(app)?;

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
    let logs_i = MenuItem::with_id(app, "view-logs", "View Logs", true, None::<&str>)?;
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
            &logs_i,
            &logout_i,
            &quit_i,
        ],
    )
    .map_err(Into::into)
}

/// Build the system tray icon with menu and event handlers.
/// Also registers the frontend logout listener.
pub fn setup(app: &tauri::App, mode: LayoutMode) -> Result<(), Box<dyn std::error::Error>> {
    let menu = build_menu(app, mode)?;

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
            "view-logs" => {
                if let Ok(log_dir) = app.path().app_log_dir() {
                    // Find the most recent .log file in the log directory
                    let log_file = std::fs::read_dir(&log_dir)
                        .ok()
                        .and_then(|entries| {
                            entries
                                .filter_map(|e| e.ok())
                                .filter(|e| {
                                    e.path().extension().is_some_and(|ext| ext == "log")
                                })
                                .max_by_key(|e| e.metadata().ok().and_then(|m| m.modified().ok()))
                                .map(|e| e.path())
                        })
                        .unwrap_or(log_dir);

                    #[cfg(target_os = "macos")]
                    let _ = std::process::Command::new("open").arg(&log_file).spawn();
                    #[cfg(target_os = "linux")]
                    let _ = std::process::Command::new("xdg-open").arg(&log_file).spawn();
                    #[cfg(target_os = "windows")]
                    let _ = std::process::Command::new("explorer").arg(&log_file).spawn();
                }
            }
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
}
