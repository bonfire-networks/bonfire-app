use std::fs;
use tauri::Builder;
// use tauri::{Builder, Manager};
// use tauri::http::Response;

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
  Builder::default()
    // .register_uri_scheme_protocol("local", move |ctx, request| {
    //   let path = request.uri().path();

    //   // Prevent directory traversal
    //   if path.contains("..") {
    //     return Response::builder()
    //       .status(403)
    //       .body(Vec::new())
    //       .expect("failed to build 403 response");
    //   }

    //   let asset_path = match ctx.app_handle().path().resolve(
    //     format!("assets{}", path),
    //     tauri::path::BaseDirectory::Resource,
    //   ) {
    //     Ok(path) => path,
    //     Err(_) => {
    //       return Response::builder()
    //         .status(400)
    //         .body(Vec::new())
    //         .expect("failed to build 400 response");
    //     }
    //   };

    //   let data = match fs::read(&asset_path) {
    //     Ok(data) => data,
    //     Err(_) => {
    //       return Response::builder()
    //         .status(404)
    //         .body(Vec::new())
    //         .expect("failed to build 404 response");
    //     }
    //   };

    //   let mime = mime_guess::from_path(&asset_path)
    //     .first_or_octet_stream();

    //   Response::builder()
    //     .header("Content-Type", mime.as_ref())
    //     .header("Access-Control-Allow-Origin", "*")
    //     .header("Cross-Origin-Resource-Policy", "same-origin")
    //     .header("Cross-Origin-Embedder-Policy", "require-corp")
    //     .body(data)
    //     .expect("failed to build response")
    // })
    .setup(|app| {
      if cfg!(debug_assertions) {
        app.handle().plugin(
          tauri_plugin_log::Builder::default()
            .level(log::LevelFilter::Info)
            .build(),
        )?;
      }
      Ok(())
    })
    .run(tauri::generate_context!())
    .expect("error while running tauri application");
}
