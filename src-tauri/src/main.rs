// Prevents additional console window on Windows in release, DO NOT REMOVE!!
#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]

use tauri::{WebviewUrl, WebviewWindowBuilder};

fn main() {
    tauri::Builder::default()
        .setup(|app| {
            let js_code = include_str!("../../priv/static/assets/e2ee_tauri_bundle.js");
            let wasm_bytes = include_bytes!("../../priv/static/assets/openmls/openmls_wasm_bg.wasm");


            // NOTE: this creates our window instead of having this in config:
            // "windows": [
            //   {
            //     "url": "pick-instance.html",
            //     "title": "Bonfire",
            //     "label": "main",
            //     "width": 800,
            //     "height": 600,
            //     "resizable": true,
            //     "fullscreen": false
            //   }
            // ],

            let _window = WebviewWindowBuilder::new(
                app,
                "main",
                WebviewUrl::App("pick-instance.html".into()), // or your default page
            )
            .initialization_script_for_all_frames(&format!(
                "{}\nwindow.__openmls_wasm = new Uint8Array({:?});\nconsole.log('local E2EE JS+WASM initialized');",
                js_code, wasm_bytes
            ))
            .build()?;

            Ok(())
        })
        .run(tauri::generate_context!())
        .expect("error while running Tauri application");
}
