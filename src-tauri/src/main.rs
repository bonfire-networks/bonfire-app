// Prevents additional console window on Windows in release, DO NOT REMOVE!!
#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]

mod commands;
mod deep_link;
mod layout;
mod notifications;
mod state;
mod tray;

use std::sync::Mutex;

use layout::{LayoutManager, LayoutMode};
use notifications::NotificationListener;
use state::{load_preferences, Preferences};
use tauri::{Manager, RunEvent};

/// Application state managed by Tauri, protected by a Mutex for thread safety.
pub struct AppState {
    pub layout_manager: LayoutManager,
    pub preferences: Preferences,
    pub notification_listener: Option<NotificationListener>,
}

fn main() {
    let app = tauri::Builder::default()
        .plugin(
            tauri_plugin_log::Builder::default()
                .level(log::LevelFilter::Info)
                .build(),
        )
        .plugin(tauri_plugin_openmls::init())
        .plugin(tauri_plugin_notification::init())
        .plugin(tauri_plugin_http::init())
        .plugin(tauri_plugin_deep_link::init())
        .invoke_handler(tauri::generate_handler![
            commands::open_secure_chat,
            commands::get_layout_mode,
            commands::set_layout_mode,
            commands::switch_tab,
            commands::get_active_tab,
            commands::show_notification,
            commands::split_resize_start,
            commands::split_resize_end,
            commands::start_notifications,
            commands::stop_notifications,
            commands::fetch_url,
            deep_link::get_startup_deep_link,
            deep_link::register_deep_link_domain,
        ])
        .setup(move |app| {
            let prefs = load_preferences(app.handle());
            let mode = LayoutMode::from_preferences(&prefs);

            let mut layout_manager = LayoutManager::new(mode, &prefs);
            if let Err(e) = layout_manager.setup(app.handle(), Some("pick-instance.html")) {
                eprintln!("Layout setup failed: {}", e);
            }

            app.manage(Mutex::new(AppState {
                layout_manager,
                preferences: prefs,
                notification_listener: None,
            }));

            tray::setup(app, mode)?;
            deep_link::setup(app);

            Ok(())
        })
        .build(tauri::generate_context!())
        .expect("Error while building Bonfire desktop app");

    app.run(|app, event| match event {
        RunEvent::ExitRequested { code, api, .. } => {
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
