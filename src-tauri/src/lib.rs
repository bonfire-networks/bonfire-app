mod commands;
mod deep_link;
mod layout;
mod notifications;
mod state;
#[cfg(desktop)]
mod tray;

use std::sync::Mutex;

use layout::{LayoutManager, LayoutMode};
use notifications::NotificationListener;
use state::{load_preferences, Preferences};
use tauri::{Manager, RunEvent};

/// Returns path to the WebKit website data directory for this app.
fn webkit_data_dir() -> Option<std::path::PathBuf> {
    let home = std::env::var("HOME").ok()?;
    Some(std::path::PathBuf::from(home)
        .join("Library/WebKit/cafe.bonfire.desktop/WebsiteData"))
}

/// Delete SQLite WAL/SHM lock files — releases locks without touching message history or MLS keys.
pub fn clear_sqlite_locks() {
    if let Some(home) = std::env::var("HOME").ok() {
        let app_data = std::path::PathBuf::from(home)
            .join("Library/Application Support/cafe.bonfire.desktop");
        if let Ok(entries) = std::fs::read_dir(&app_data) {
            for entry in entries.flatten() {
                let path = entry.path();
                if let Some(ext) = path.extension().and_then(|e| e.to_str()) {
                    if ext == "wal" || ext == "shm" {
                        let _ = std::fs::remove_file(&path);
                    }
                }
            }
        }
    }
}

/// Delete IndexedDB and LocalStorage — clears cached message history without touching MLS keys.
pub fn clear_indexeddb() {
    if let Some(dir) = webkit_data_dir() {
        for sub in &["IndexedDB", "LocalStorage"] {
            let path = dir.join(sub);
            if path.exists() {
                let _ = std::fs::remove_dir_all(&path);
            }
        }
    }
}

/// Delete both SQLite WAL/SHM files and IndexedDB/LocalStorage.
pub fn clear_chat_storage() {
    clear_sqlite_locks();
    clear_indexeddb();
}

/// Path to the startup dirty flag file (in app data dir).
fn dirty_flag_path(app: &tauri::AppHandle) -> Option<std::path::PathBuf> {
    app.path().app_data_dir().ok().map(|d| d.join(".startup_dirty"))
}

fn write_dirty_flag(app: &tauri::AppHandle) {
    if let Some(p) = dirty_flag_path(app) {
        let _ = std::fs::write(&p, b"1");
    }
}

fn clear_dirty_flag(app: &tauri::AppHandle) {
    if let Some(p) = dirty_flag_path(app) {
        let _ = std::fs::remove_file(&p);
    }
}

fn dirty_flag_exists(app: &tauri::AppHandle) -> bool {
    dirty_flag_path(app).is_some_and(|p| p.exists())
}

/// Set to true when an unclean shutdown is detected; read by webview initialization scripts.
pub static JS_DEBUG_MODE: std::sync::atomic::AtomicBool =
    std::sync::atomic::AtomicBool::new(false);

/// Application state managed by Tauri, protected by a Mutex for thread safety.
pub struct AppState {
    pub layout_manager: LayoutManager,
    pub preferences: Preferences,
    pub notification_listener: Option<NotificationListener>,
}

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    let mut builder = tauri::Builder::default()
        .plugin(
            tauri_plugin_log::Builder::default()
                .level(log::LevelFilter::Info)
                .build(),
        )
        .plugin(tauri_plugin_openmls::init())
        .plugin(tauri_plugin_notification::init())
        .plugin(tauri_plugin_http::init())
        .plugin(tauri_plugin_deep_link::init())
        .plugin(tauri_plugin_dialog::init())
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
            commands::show_crash_dialog,
            commands::signal_app_ready,
            commands::check_skip_storage,
            commands::js_log,
        ]);

        #[cfg(feature = "e2e-testing")]
        {
            builder = builder.plugin(tauri_plugin_playwright::init());
        }

        let app = builder.setup(move |app| {
            let prefs = load_preferences(app.handle());
            #[allow(unused_variables)]
            let mode = LayoutMode::from_preferences(&prefs);

            #[cfg(desktop)]
            {
                // Detect unclean shutdown — enable JS debug logging and offer recovery options
                let had_dirty_quit = dirty_flag_exists(app.handle());
                if had_dirty_quit {
                    JS_DEBUG_MODE.store(true, std::sync::atomic::Ordering::SeqCst);
                    use tauri_plugin_dialog::{DialogExt, MessageDialogButtons, MessageDialogKind};
                    let handle = app.handle().clone();
                    let clear_locks = app.dialog()
                        .message(
                            "The app did not shut down cleanly last time.\n\n\
                            \"Clear DB locks\" releases SQLite locks — no data is deleted (try this first).\n\n\
                            \"Debug options\" lets you start while skipping specific storage layers to isolate a freeze.",
                        )
                        .title("Unclean shutdown")
                        .kind(MessageDialogKind::Warning)
                        .buttons(MessageDialogButtons::OkCancelCustom(
                            "Clear DB locks & start".into(),
                            "Debug options…".into(),
                        ))
                        .blocking_show();
                    if clear_locks {
                        clear_sqlite_locks();
                    } else {
                        let skip_attachments = app.dialog()
                            .message(
                                "Start skipping:\n\n\
                                • \"Skip attachments\" — messages load, no attachment files\n\
                                • \"Skip all\" — only group list loads",
                            )
                            .title("Debug: skip storage")
                            .kind(MessageDialogKind::Warning)
                            .buttons(MessageDialogButtons::OkCancelCustom(
                                "Skip attachments".into(),
                                "Skip all".into(),
                            ))
                            .blocking_show();
                        let scope_str = if skip_attachments {
                            let skip_previews = app.dialog()
                                .message(
                                    "Narrow down further:\n\n\
                                    • \"Skip previews\" — files decompressed, thumbnail generation skipped\n\
                                    • \"Skip files\" — no decompression at all",
                                )
                                .title("Debug: attachment scope")
                                .kind(MessageDialogKind::Warning)
                                .buttons(MessageDialogButtons::OkCancelCustom(
                                    "Skip previews".into(),
                                    "Skip files".into(),
                                ))
                                .blocking_show();
                            if skip_previews { "previews" } else { "attachments" }
                        } else {
                            "all"
                        };
                        if let Ok(data_dir) = app.handle().path().app_data_dir() {
                            let _ = std::fs::write(data_dir.join(".skip_storage"), scope_str);
                        }
                    }
                    clear_dirty_flag(&handle);
                }
                write_dirty_flag(app.handle());

                let mut layout_manager = LayoutManager::new(mode, &prefs);
                if let Err(e) = layout_manager.setup(app.handle(), Some("pick-instance.html")) {
                    eprintln!("Layout setup failed: {}", e);
                }
                // Start watchdog if chat webview is created at startup (tab/split modes)
                if layout_manager.has_chat_webview() {
                    commands::start_chat_watchdog(app.handle().clone(), 10);
                }
                app.manage(Mutex::new(AppState {
                    layout_manager,
                    preferences: prefs,
                    notification_listener: None,
                }));
                tray::setup(app, mode)?;
            }

            #[cfg(mobile)]
            {
                // Mobile: single WebviewWindow with bottom nav bar injected on every page
                use tauri::WebviewUrl;
                let ww = tauri::WebviewWindowBuilder::new(
                    app,
                    "main",
                    WebviewUrl::App("pick-instance.html".into()),
                )
                .initialization_script(include_str!(
                    "../../extensions/bonfire_ui_common/assets/static/tauri/mobile-nav.js"
                ))
                .build()
                .map_err(|e| format!("Mobile window setup failed: {e}"))?;

                let mut layout_manager = LayoutManager::new(LayoutMode::TabBased, &prefs);

                // Capture local asset origin for tab navigation URLs
                let local_origin = ww
                    .url()
                    .ok()
                    .and_then(|url| {
                        url.host_str()
                            .map(|host| format!("{}://{}", url.scheme(), host))
                    })
                    .unwrap_or_else(|| "http://tauri.localhost".to_string());
                layout_manager.set_local_origin(local_origin);

                app.manage(Mutex::new(AppState {
                    layout_manager,
                    preferences: prefs,
                    notification_listener: None,
                }));
            }

            deep_link::setup(app);

            Ok(())
        })
        .build(tauri::generate_context!())
        .expect("Error while building Bonfire app");

    app.run(|#[allow(unused_variables)] app, event| match event {
        RunEvent::ExitRequested { code, api, .. } => {
            if code.is_none() {
                // Last window closed on macOS — keep app alive in dock, clear flag (clean state)
                api.prevent_exit();
                clear_dirty_flag(app);
            } else {
                // Clean exit via app.exit()
                clear_dirty_flag(app);
            }
        }
        RunEvent::Exit => {
            clear_dirty_flag(app);
        }
        #[cfg(desktop)]
        RunEvent::WindowEvent {
            label,
            event: tauri::WindowEvent::CloseRequested { .. },
            ..
        } => {
            let state_mutex = app.state::<Mutex<AppState>>();
            let Ok(state) = state_mutex.lock() else { return };
            state.layout_manager.save_window_by_label(app, &label);
        }
        #[cfg(desktop)]
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
