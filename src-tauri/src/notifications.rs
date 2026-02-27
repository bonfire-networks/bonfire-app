//! SSE-based notification listener for real-time push from the Bonfire server.
//!
//! Connects to the server's `/api/v1-bonfire/streaming` SSE endpoint after login,
//! delivers OS-native notifications, and emits Tauri events so webviews
//! can refresh. Auto-reconnects on connection drops (built into
//! `reqwest-eventsource`). Stopped on logout via a `tokio::sync::watch` channel.

use futures_util::StreamExt;
use reqwest_eventsource::{Event, RequestBuilderExt};
use serde::Deserialize;
use tauri::Emitter;
use tauri_plugin_notification::NotificationExt;
use tokio::sync::watch;

/// Manages the background SSE listener task.
pub struct NotificationListener {
    cancel_tx: watch::Sender<bool>,
}

/// Deserialized notification SSE event payload.
#[derive(Debug, Deserialize)]
struct NotificationPayload {
    title: Option<String>,
    body: Option<String>,
    #[allow(dead_code)]
    url: Option<String>,
    #[allow(dead_code)]
    icon: Option<String>,
}

/// Deserialized message SSE event payload.
#[derive(Debug, Deserialize)]
#[allow(dead_code)]
struct MessagePayload {
    thread_id: Option<String>,
}

impl NotificationListener {
    /// Spawns a background task that connects to the SSE streaming endpoint
    /// and delivers OS notifications + Tauri events until cancelled.
    pub fn start(app: tauri::AppHandle, instance_url: String, token: String) -> Self {
        let (cancel_tx, cancel_rx) = watch::channel(false);

        eprintln!("[SSE] Starting notification listener for {}", instance_url);
        tauri::async_runtime::spawn(async move {
            sse_loop(app, instance_url, token, cancel_rx).await;
            eprintln!("[SSE] Notification listener task exited");
        });

        Self { cancel_tx }
    }

    /// Signals the background task to stop.
    pub fn stop(&self) {
        eprintln!("[SSE] Stopping notification listener");
        let _ = self.cancel_tx.send(true);
    }
}

/// The main SSE event loop. Reconnects with exponential backoff on failures.
async fn sse_loop(
    app: tauri::AppHandle,
    instance_url: String,
    token: String,
    mut cancel_rx: watch::Receiver<bool>,
) {
    let url = format!(
        "{}/api/v1-bonfire/streaming?stream=user:notification",
        instance_url.trim_end_matches('/')
    );

    let client = reqwest::Client::new();
    let mut backoff_secs: u64 = 1;
    const MAX_BACKOFF_SECS: u64 = 60;

    loop {
        // Check cancellation before (re)connecting
        if *cancel_rx.borrow() {
            break;
        }

        eprintln!("[SSE] Connecting to {}", url);
        let mut es = client
            .get(&url)
            .header("Authorization", format!("Bearer {}", token))
            .eventsource()
            .unwrap();

        let mut fatal = false;

        loop {
            tokio::select! {
                _ = cancel_rx.changed() => {
                    if *cancel_rx.borrow() {
                        eprintln!("[SSE] Cancel signal received, closing connection");
                        es.close();
                        fatal = true;
                        break;
                    }
                }
                event = es.next() => {
                    match event {
                        Some(Ok(Event::Open)) => {
                            eprintln!("[SSE] Connection opened to {}", url);
                            // Reset backoff on successful connection
                            backoff_secs = 1;
                        }
                        Some(Ok(Event::Message(msg))) => {
                            eprintln!("[SSE] Received event: type={}, data_len={}", msg.event, msg.data.len());
                            handle_sse_message(&app, &msg.event, &msg.data);
                        }
                        Some(Err(err)) => {
                            eprintln!("[SSE] Error: {:?}", err);
                            match &err {
                                reqwest_eventsource::Error::InvalidStatusCode(status, resp) => {
                                    eprintln!("[SSE] Status: {}, headers: {:?}", status, resp.headers());
                                    if status.as_u16() == 401 || status.as_u16() == 403 {
                                        eprintln!("[SSE] Auth failed ({}), stopping permanently", status);
                                        es.close();
                                        fatal = true;
                                        break;
                                    }
                                    // Other HTTP errors (502, 503, etc.) — break inner loop to reconnect
                                    es.close();
                                    break;
                                }
                                reqwest_eventsource::Error::InvalidContentType(_, resp) => {
                                    eprintln!("[SSE] Wrong content-type, headers: {:?}", resp.headers());
                                    es.close();
                                    fatal = true;
                                    break;
                                }
                                _ => {
                                    // Transport errors — reqwest-eventsource may auto-reconnect,
                                    // but if the stream ends after this we'll reconnect ourselves
                                }
                            }
                        }
                        None => {
                            eprintln!("[SSE] Stream ended");
                            break;
                        }
                    }
                }
            }
        }

        if fatal {
            break;
        }

        // Exponential backoff before reconnecting
        eprintln!("[SSE] Reconnecting in {} seconds...", backoff_secs);
        tokio::select! {
            _ = tokio::time::sleep(std::time::Duration::from_secs(backoff_secs)) => {}
            _ = cancel_rx.changed() => {
                if *cancel_rx.borrow() {
                    break;
                }
            }
        }
        backoff_secs = (backoff_secs * 2).min(MAX_BACKOFF_SECS);
    }
}

/// Dispatches a single SSE message to OS notification and/or Tauri event.
fn handle_sse_message(app: &tauri::AppHandle, event_type: &str, data: &str) {
    match event_type {
        "notification" => {
            match serde_json::from_str::<NotificationPayload>(data) {
                Ok(payload) => {
                    let title = payload.title.as_deref().unwrap_or("Bonfire");
                    let body = payload.body.as_deref().unwrap_or("");
                    eprintln!("[SSE] Notification: title={:?}, body={:?}", title, body);

                    // OS notification
                    if let Err(e) = app
                        .notification()
                        .builder()
                        .title(title)
                        .body(body)
                        .show()
                    {
                        eprintln!("[SSE] Failed to show OS notification: {}", e);
                    }

                    // Tauri event for webview refresh
                    let _ = app.emit("new-notification", data);
                }
                Err(e) => {
                    eprintln!("[SSE] Failed to parse notification payload: {} — data: {}", e, data);
                }
            }
        }
        "message" => {
            eprintln!("[SSE] Message event: {}", data);
            // Tauri event for chat webview refresh
            let _ = app.emit("new-message", data);
        }
        other => {
            eprintln!("[SSE] Unknown event type: {} — data: {}", other, data);
        }
    }
}
