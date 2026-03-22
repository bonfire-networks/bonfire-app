use std::sync::Mutex;

use tauri::menu::{Menu, MenuItem, PredefinedMenuItem, Submenu};
use tauri::tray::TrayIconBuilder;
use tauri::{Listener, Manager};

use crate::layout::LayoutMode;
use crate::state::save_preferences;
use crate::{clear_chat_storage, AppState};

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

/// Handles a menu event by ID. Shared between tray and app menu bar.
pub fn handle_menu_event(app: &tauri::AppHandle, id: &str) {
    match id {
        "show" => {
            let state_mutex = app.state::<Mutex<AppState>>();
            let Ok(mut state) = state_mutex.lock() else { return };
            state.layout_manager.show_main(app);
        }
        "messages" => show_messages_window(app),
        "devtools" => {
            #[cfg(debug_assertions)]
            {
                // Prefer chat webview; fall back to main
                // Prefer chat webview; fall back to main; last resort chrome-bar
                for label in &["chat-webview", "main-webview", "chrome-bar"] {
                    if let Some(wv) = app.get_webview(label) {
                        wv.open_devtools();
                        break;
                    }
                    if let Some(wv) = app.get_webview_window(label) {
                        wv.open_devtools();
                        break;
                    }
                }
            }
        }
        "view-logs" => {
            if let Ok(log_dir) = app.path().app_log_dir() {
                let log_file = std::fs::read_dir(&log_dir)
                    .ok()
                    .and_then(|entries| {
                        entries
                            .filter_map(|e| e.ok())
                            .filter(|e| e.path().extension().is_some_and(|ext| ext == "log"))
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
        "clear-db-locks" => {
            use tauri_plugin_dialog::{DialogExt, MessageDialogButtons, MessageDialogKind};
            use tauri::Manager;
            let handle = app.clone();
            let confirmed = app.dialog()
                .message("This will release any SQLite database locks from an interrupted operation. No data will be deleted.\n\nContinue?")
                .title("Clear DB Locks")
                .kind(MessageDialogKind::Warning)
                .buttons(MessageDialogButtons::OkCancelCustom("Clear locks & reload".into(), "Cancel".into()))
                .blocking_show();
            if confirmed {
                crate::clear_sqlite_locks();
                for label in &["chat-webview", "main-webview"] {
                    if let Some(wv) = handle.get_webview(label) {
                        let _ = wv.eval("location.reload()");
                    }
                }
            }
        }
        "clear-chat-data" => {
            use tauri_plugin_dialog::{DialogExt, MessageDialogButtons, MessageDialogKind};
            use tauri::Manager;
            let handle = app.clone();
            let confirmed = app.dialog()
                .message("This will delete your local chat message history. Your account and encryption keys are not affected.\n\nContinue?")
                .title("Clear Chat Data")
                .kind(MessageDialogKind::Warning)
                .buttons(MessageDialogButtons::OkCancelCustom("Clear".into(), "Cancel".into()))
                .blocking_show();
            if confirmed {
                clear_chat_storage();
                for label in &["chat-webview", "main-webview"] {
                    if let Some(wv) = handle.get_webview(label) {
                        let _ = wv.eval("location.reload()");
                    }
                }
            }
        }
        "logout" => logout(app),
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
    }
}

/// Shared menu items used in both the tray menu and the macOS app menu bar.
/// Returns `(window_items, layout_items, tools_items)` — callers arrange them as needed.
fn build_shared_items<M: tauri::Runtime>(
    app: &impl tauri::Manager<M>,
    current_mode: LayoutMode,
) -> Result<SharedMenuItems<M>, Box<dyn std::error::Error>> {
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

    Ok(SharedMenuItems {
        show: MenuItem::with_id(app, "show", "Show Bonfire", true, None::<&str>)?,
        messages: MenuItem::with_id(app, "messages", "Messages", true, None::<&str>)?,
        layout_mw: MenuItem::with_id(app, "layout-multi-window", &mw_label, true, None::<&str>)?,
        layout_sp: MenuItem::with_id(app, "layout-split-pane", &sp_label, true, None::<&str>)?,
        layout_tb: MenuItem::with_id(app, "layout-tab-based", &tb_label, true, None::<&str>)?,
        view_logs: MenuItem::with_id(app, "view-logs", "View Logs", true, None::<&str>)?,
        devtools: MenuItem::with_id(app, "devtools", "Open DevTools", true, None::<&str>)?,
        clear_db_locks: MenuItem::with_id(app, "clear-db-locks", "Clear DB Locks…", true, None::<&str>)?,
        clear_chat: MenuItem::with_id(app, "clear-chat-data", "Clear Chat Data…", true, None::<&str>)?,
        logout: MenuItem::with_id(app, "logout", "Log out", true, None::<&str>)?,
        quit: PredefinedMenuItem::quit(app, Some("Quit Bonfire"))?,
        sep1: PredefinedMenuItem::separator(app)?,
        sep2: PredefinedMenuItem::separator(app)?,
    })
}

struct SharedMenuItems<R: tauri::Runtime> {
    show: MenuItem<R>,
    messages: MenuItem<R>,
    layout_mw: MenuItem<R>,
    layout_sp: MenuItem<R>,
    layout_tb: MenuItem<R>,
    view_logs: MenuItem<R>,
    devtools: MenuItem<R>,
    clear_db_locks: MenuItem<R>,
    clear_chat: MenuItem<R>,
    logout: MenuItem<R>,
    quit: PredefinedMenuItem<R>,
    sep1: PredefinedMenuItem<R>,
    sep2: PredefinedMenuItem<R>,
}

fn build_tray_menu(
    app: &tauri::App,
    current_mode: LayoutMode,
) -> Result<Menu<tauri::Wry>, Box<dyn std::error::Error>> {
    let i = build_shared_items(app, current_mode)?;
    Menu::with_items(
        app,
        &[
            &i.show,
            &i.messages,
            &i.sep1,
            &i.layout_mw,
            &i.layout_sp,
            &i.layout_tb,
            &i.sep2,
            &i.view_logs,
            &i.devtools,
            &i.clear_db_locks,
            &i.clear_chat,
            &i.logout,
            &i.quit,
        ],
    )
    .map_err(Into::into)
}

/// Builds the macOS native app menu bar (File / View / Window / Help pattern).
fn build_app_menu(
    app: &tauri::App,
    current_mode: LayoutMode,
) -> Result<Menu<tauri::Wry>, Box<dyn std::error::Error>> {
    let i = build_shared_items(app, current_mode)?;

    // Bonfire menu (leftmost, named after the app)
    let app_menu = Submenu::with_items(
        app,
        "Bonfire",
        true,
        &[&i.show, &i.messages, &i.sep1, &i.clear_db_locks, &i.clear_chat, &i.logout, &i.quit],
    )?;

    // View menu — layout modes
    let layout_sep = PredefinedMenuItem::separator(app)?;
    let view_menu = Submenu::with_items(
        app,
        "View",
        true,
        &[
            &i.layout_mw,
            &i.layout_sp,
            &i.layout_tb,
            &layout_sep,
            &i.view_logs,
            &i.devtools,
        ],
    )?;

    Menu::with_items(app, &[&app_menu, &view_menu]).map_err(Into::into)
}

/// Build the system tray icon and macOS app menu bar, sharing event handling.
/// Also registers the frontend logout listener.
pub fn setup(app: &tauri::App, mode: LayoutMode) -> Result<(), Box<dyn std::error::Error>> {
    let tray_menu = build_tray_menu(app, mode)?;

    let _tray = TrayIconBuilder::new()
        .icon(app.default_window_icon().unwrap().clone())
        .menu(&tray_menu)
        .show_menu_on_left_click(true)
        .on_menu_event(|app, event| handle_menu_event(app, event.id.as_ref()))
        .build(app)?;

    // macOS app menu bar — shares the same item IDs and handler
    #[cfg(target_os = "macos")]
    {
        let app_menu = build_app_menu(app, mode)?;
        app.set_menu(app_menu)?;
        app.on_menu_event(|app, event| handle_menu_event(app, event.id.as_ref()));
    }

    // Listen for logout event from the frontend
    let handle = app.handle().clone();
    app.listen("app-logout", move |_event| {
        logout(&handle);
    });

    Ok(())
}
