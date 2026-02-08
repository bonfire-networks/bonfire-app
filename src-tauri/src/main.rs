// Prevents additional console window on Windows in release, DO NOT REMOVE!!
#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]

use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use std::fs;
use std::path::PathBuf;
use tauri::{
    menu::{Menu, MenuItem},
    tray::TrayIconBuilder,
    Listener, Manager, RunEvent, WebviewUrl, WebviewWindow, WebviewWindowBuilder,
};

#[derive(Serialize, Deserialize, Clone, Debug)]
struct WindowGeometry {
    x: f64,
    y: f64,
    width: f64,
    height: f64,
}

fn state_path(app: &tauri::AppHandle) -> PathBuf {
    let dir = app.path().app_data_dir().expect("no app data dir");
    let _ = fs::create_dir_all(&dir);
    dir.join("window-state.json")
}

fn load_state(app: &tauri::AppHandle) -> HashMap<String, WindowGeometry> {
    fs::read_to_string(state_path(app))
        .ok()
        .and_then(|s| serde_json::from_str(&s).ok())
        .unwrap_or_default()
}

fn save_window_state(app: &tauri::AppHandle, label: &str, window: &WebviewWindow) {
    let scale = window.scale_factor().unwrap_or(1.0);
    let Some(pos) = window.outer_position().ok() else { return };
    let Some(size) = window.outer_size().ok() else { return };

    let geom = WindowGeometry {
        x: pos.x as f64 / scale,
        y: pos.y as f64 / scale,
        width: size.width as f64 / scale,
        height: size.height as f64 / scale,
    };

    let mut state = load_state(app);
    state.insert(label.to_string(), geom);

    if let Ok(json) = serde_json::to_string_pretty(&state) {
        let _ = fs::write(state_path(app), json);
    }
}

/// Get the primary monitor's logical size (accounts for scale factor on Retina etc).
fn logical_screen_size(app: &tauri::AppHandle) -> (f64, f64) {
    app.primary_monitor()
        .ok()
        .flatten()
        .map(|m| {
            let s = m.size();
            let scale = m.scale_factor();
            (s.width as f64 / scale, s.height as f64 / scale)
        })
        .unwrap_or((1920.0, 1080.0))
}

/// Show or create the main window with the given URL.
fn ensure_main_window(app: &tauri::AppHandle, url: WebviewUrl) {
    if let Some(window) = app.get_webview_window("main") {
        let _ = window.show();
        let _ = window.set_focus();
        return;
    }

    let state = load_state(app);
    let (sw, sh) = logical_screen_size(app);
    let default_w = (sw * 2.0 / 2.9).round();

    let geom = state.get("main").cloned().unwrap_or(WindowGeometry {
        x: 0.0,
        y: 0.0,
        width: default_w,
        height: sh,
    });

    let _ = WebviewWindowBuilder::new(app, "main", url)
        .title("Bonfire")
        .position(geom.x, geom.y)
        .inner_size(geom.width, geom.height)
        .build();
}

#[tauri::command]
async fn open_secure_chat(app: tauri::AppHandle) -> Result<(), String> {
    // If the window already exists, just focus it
    if let Some(window) = app.get_webview_window("secure-chat") {
        window.set_focus().map_err(|e| e.to_string())?;
        return Ok(());
    }

    let state = load_state(&app);
    let (sw, sh) = logical_screen_size(&app);
    let main_w = (sw * 2.0 / 2.9).round();
    let chat_w = sw - main_w;

    let geom = state
        .get("secure-chat")
        .cloned()
        .unwrap_or(WindowGeometry {
            x: main_w,
            y: 0.0,
            width: chat_w,
            height: sh,
        });

    // let js_code = include_str!("../../priv/static/assets/e2ee_tauri_bundle.js");
    // let wasm_bytes = include_bytes!("../../priv/static/assets/openmls/openmls_wasm_bg.wasm");

    WebviewWindowBuilder::new(
        &app,
        "secure-chat",
        WebviewUrl::App("assets/ap_c2s_client/index.html".into()),
    )
    .title("Secure Chat")
    .inner_size(geom.width, geom.height)
    .position(geom.x, geom.y)
    // inject user script in the webview
    // .initialization_script(&format!(
    //     "{}\nwindow.__openmls_wasm = new Uint8Array({:?});\nconsole.log('local E2EE JS+WASM initialized');",
    //     js_code, wasm_bytes
    // ))
    .build()
    .map_err(|e| e.to_string())?;

    // Resize main window to fit beside chat if using default layout
    if state.get("main").is_none() {
        if let Some(main_win) = app.get_webview_window("main") {
            let _ = main_win.set_size(tauri::LogicalSize::new(main_w, sh));
            let _ = main_win.set_position(tauri::LogicalPosition::new(0.0, 0.0));
        }
    }

    Ok(())
}

fn show_messages_window(app: &tauri::AppHandle) {
    if let Some(window) = app.get_webview_window("secure-chat") {
        let _ = window.show();
        let _ = window.set_focus();
    } else {
        let _ = tauri::async_runtime::block_on(open_secure_chat(app.clone()));
    }
}

fn logout(app: &tauri::AppHandle) {
    // Close secure-chat window if open
    if let Some(window) = app.get_webview_window("secure-chat") {
        let _ = window.destroy();
    }
    // Save main window state and destroy it, then recreate at pick-instance
    // (navigate() doesn't resolve App asset paths, so we recreate instead)
    if let Some(window) = app.get_webview_window("main") {
        save_window_state(app, "main", &window);
        let _ = window.destroy();
    }
    ensure_main_window(
        app,
        WebviewUrl::App("pick-instance.html#logout".into()),
    );
}

fn main() {
    let app = tauri::Builder::default()
        .plugin(tauri_plugin_openmls::init())
        .invoke_handler(tauri::generate_handler![open_secure_chat])
        .setup(|app| {
            ensure_main_window(
                app.handle(),
                WebviewUrl::App("pick-instance.html".into()),
            );

            // Tray menu
            let show_i = MenuItem::with_id(app, "show", "Show Bonfire", true, None::<&str>)?;
            let messages_i = MenuItem::with_id(app, "messages", "Messages", true, None::<&str>)?;
            let logout_i = MenuItem::with_id(app, "logout", "Log out", true, None::<&str>)?;
            let quit_i = MenuItem::with_id(app, "quit", "Quit", true, None::<&str>)?;
            let menu = Menu::with_items(app, &[&show_i, &messages_i, &logout_i, &quit_i])?;

            let _tray = TrayIconBuilder::new()
                .icon(app.default_window_icon().unwrap().clone())
                .menu(&menu)
                .show_menu_on_left_click(true)
                .on_menu_event(|app, event| match event.id.as_ref() {
                    "show" => ensure_main_window(app, WebviewUrl::App("pick-instance.html".into())),
                    "messages" => show_messages_window(app),
                    "logout" => logout(app),
                    "quit" => app.exit(0),
                    _ => {}
                })
                .build(app)?;

            // Listen for logout event from the frontend (e.g. secure-chat webview)
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
            if let Some(window) = app.get_webview_window(&label) {
                save_window_state(app, &label, &window);
            }
        }
        _ => {}
    });
}
