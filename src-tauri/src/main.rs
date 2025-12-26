// Prevents additional console window on Windows in release, DO NOT REMOVE!!
#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]

use tauri::WebviewWindow;

#[tauri::command]
fn navigate_to(window: WebviewWindow, url: String) -> Result<(), String> {
    window.eval(&format!("window.location.href = '{}'", url))
        .map_err(|e| e.to_string())
}

fn main() {
    tauri::Builder::default()
        .invoke_handler(tauri::generate_handler![navigate_to])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}