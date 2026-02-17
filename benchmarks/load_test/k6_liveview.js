// Bonfire Load Test with LiveView WebSocket Support
//
// Measures the FULL page lifecycle: HTTP response + WebSocket LiveView mount.
// This captures what users actually experience, since LiveView loads feed data
// asynchronously after the WebSocket connects.
//
// Usage:
//   k6 run -e COOKIE="your_cookie" benchmarks/load_test/k6_liveview.js
//
// Options:
//   HOST     - Target host (default: localhost:4000)
//   COOKIE   - Session cookie value (required)
//   HTTPS    - Set to "1" for https (default: http)
//   VUS      - Number of concurrent users (default: 10)
//   DURATION - Test duration (default: 60s)
//   PAGE     - Page to test (default: /feed/explore)
//   WAIT     - Seconds to wait for async diffs after mount (default: 10)
//   TIMEOUT  - Hard WS timeout in seconds (default: 15)
//
// Examples:
//   k6 run -e COOKIE="..." benchmarks/load_test/k6_liveview.js
//   k6 run -e COOKIE="..." -e VUS=50 -e DURATION=2m benchmarks/load_test/k6_liveview.js
//   k6 run -e COOKIE="..." -e PAGE=/feed/my benchmarks/load_test/k6_liveview.js

import http from "k6/http";
import { check, sleep } from "k6";
import { Trend, Rate, Counter } from "k6/metrics";
import ws from "k6/ws";

// --- Custom metrics ---

// HTTP phase: initial page load
const httpDuration = new Trend("bonfire_http_duration", true);
// WebSocket phase: time from WS connect to LiveView mount complete
const wsMountDuration = new Trend("bonfire_ws_mount_duration", true);
// Full lifecycle: HTTP + WS until all diffs settle
const fullPageDuration = new Trend("bonfire_full_page_duration", true);
// Time to receive first async diff (feed data arriving)
const firstDiffDuration = new Trend("bonfire_first_diff_duration", true);
// Time to receive last async diff (page fully rendered)
const lastDiffDuration = new Trend("bonfire_last_diff_duration", true);
// Number of diffs received per page load
const diffCount = new Trend("bonfire_diff_count");

const pageSuccessRate = new Rate("bonfire_page_success_rate");
const wsConnectRate = new Rate("bonfire_ws_connect_rate");
const pageErrors = new Counter("bonfire_page_errors");

// --- Config ---
const host = __ENV.HOST || "localhost:4000";
const cookie = __ENV.COOKIE;
const https = __ENV.HTTPS === "1";
const debug = __ENV.DEBUG === "1";
const protocol = https ? "https" : "http";
const wsProtocol = https ? "wss" : "ws";
const vus = parseInt(__ENV.VUS || "10");
const duration = __ENV.DURATION || "60s";
const page = __ENV.PAGE || "/feed/explore";
const diffWait = parseInt(__ENV.WAIT || "10") * 1000;
const hardTimeout = parseInt(__ENV.TIMEOUT || "15") * 1000;

export const options = {
  scenarios: {
    liveview_load: {
      executor: "constant-vus",
      vus: vus,
      duration: duration,
    },
  },
  thresholds: {
    bonfire_full_page_duration: ["p(95)<10000"],
    bonfire_page_success_rate: ["rate>0.90"],
  },
};

// --- Helpers ---

// Extract a regex match from HTML
function extractFromHtml(html, regex) {
  const match = html.match(regex);
  return match ? match[1] : null;
}

// Extract the opening tag that contains `data-phx-main`.
// We can't use a single regex because the tag may span multiple lines
// or be very long, so we find the marker and then walk to `<` and `>`.
function extractMainTag(html) {
  const marker = "data-phx-main";
  const idx = html.indexOf(marker);
  if (idx === -1) return "";

  // Walk backward to find the opening `<`
  let start = idx;
  while (start > 0 && html[start] !== "<") start--;

  // Walk forward to find the closing `>`
  let end = idx;
  while (end < html.length && html[end] !== ">") end++;

  return html.substring(start, end + 1);
}

// Parse Phoenix LiveView tokens from the page HTML
function parseLiveViewTokens(html) {
  // CSRF token from meta tag (content may appear before or after name)
  const csrfToken =
    extractFromHtml(html, /meta[^>]+name="csrf-token"[^>]+content="([^"]+)"/) ||
    extractFromHtml(html, /meta[^>]+content="([^"]+)"[^>]+name="csrf-token"/);

  // Extract tokens specifically from the MAIN LiveView element (has data-phx-main).
  // Pages may have multiple LiveView elements (e.g., embedded LoginLive) — we need the main one.
  const mainTag = extractMainTag(html);

  // Use the main tag if found, otherwise fall back to full HTML.
  // Authenticated pages typically have only one LiveView (no embedded LoginLive),
  // so data-phx-main may not be present — falling back to full HTML is safe.
  const searchIn = mainTag || html;

  const phxSession = extractFromHtml(searchIn, /data-phx-session="([^"]+)"/);
  const phxStatic = extractFromHtml(searchIn, /data-phx-static="([^"]+)"/);

  // The id attribute may appear before or after data-phx-session on the same tag.
  // Try to extract from the tag containing data-phx-session using indexOf approach.
  let phxId = null;
  const sessionIdx = searchIn.indexOf("data-phx-session");
  if (sessionIdx > -1) {
    const tagStart = searchIn.lastIndexOf("<", sessionIdx);
    const tagEnd = searchIn.indexOf(">", sessionIdx);
    const tag = searchIn.substring(tagStart, tagEnd + 1);
    phxId = extractFromHtml(tag, /id="([^"]+)"/);
  }

  return { csrfToken, phxSession, phxStatic, phxId };
}

// --- Setup ---
export function setup() {
  if (!cookie) {
    console.error(
      "COOKIE env var required. Get it from browser DevTools (copy _bonfire_key value)."
    );
    return { error: "no_cookie" };
  }

  // Test connection and verify we can extract LV tokens
  const res = http.get(`${protocol}://${host}${page}`, {
    cookies: { _bonfire_key: cookie },
  });

  if (res.status !== 200) {
    console.error(`Setup failed: status ${res.status}`);
    return { error: "connection_failed", status: res.status };
  }

  const tokens = parseLiveViewTokens(res.body);

  if (!tokens.csrfToken || !tokens.phxSession) {
    console.error("Setup failed: could not extract LiveView tokens from page");
    console.error(
      `  csrf: ${tokens.csrfToken ? "ok" : "MISSING"}, session: ${tokens.phxSession ? "ok" : "MISSING"}`
    );
    return { error: "no_lv_tokens" };
  }

  console.log(`\n=== Bonfire LiveView Load Test ===`);
  console.log(`Host: ${protocol}://${host}`);
  console.log(`Page: ${page}`);
  console.log(`VUs: ${vus}`);
  console.log(`Duration: ${duration}`);
  console.log(`LiveView ID: ${tokens.phxId}`);
  console.log(`\nMonitor: ${protocol}://${host}/admin/system\n`);

  return { ok: true };
}

// --- Main test function ---
export default function (data) {
  if (data.error) {
    sleep(1);
    return;
  }

  const fullStart = Date.now();
  let httpOk = false;
  let wsOk = false;

  // Phase 1: HTTP - Load the page
  const httpStart = Date.now();
  const res = http.get(`${protocol}://${host}${page}`, {
    cookies: { _bonfire_key: cookie },
    tags: { name: "liveview_page" },
  });
  const httpTime = Date.now() - httpStart;
  httpDuration.add(httpTime);

  httpOk = check(res, {
    "http status 200": (r) => r.status === 200,
    "has liveview": (r) => r.body && r.body.includes("data-phx-session"),
  });

  if (!httpOk) {
    pageSuccessRate.add(0);
    wsConnectRate.add(0);
    pageErrors.add(1);
    sleep(Math.random() * 2 + 1);
    return;
  }

  // Extract LiveView tokens from the response
  const tokens = parseLiveViewTokens(res.body);

  if (!tokens.csrfToken || !tokens.phxSession) {
    pageSuccessRate.add(0);
    wsConnectRate.add(0);
    pageErrors.add(1);
    sleep(Math.random() * 2 + 1);
    return;
  }

  // Phase 2: WebSocket - Connect and join the LiveView
  const wsUrl = `${wsProtocol}://${host}/live/websocket?_csrf_token=${encodeURIComponent(tokens.csrfToken)}&vsn=2.0.0`;

  const wsStart = Date.now();
  let mountTime = null;
  let firstDiffTime = null;
  let lastDiffTime = null;
  let totalDiffs = 0;
  let gotJoinReply = false;
  let gotFirstDiff = false;
  let mountError = false;
  let msgRef = 0;

  const wsRes = ws.connect(
    wsUrl,
    {
      cookies: { _bonfire_key: cookie },
      tags: { name: "liveview_ws" },
    },
    function (socket) {
      // Send heartbeat to keep connection alive
      socket.setInterval(function () {
        socket.send(
          JSON.stringify([null, String(++msgRef), "phoenix", "heartbeat", {}])
        );
      }, 30000);

      socket.on("open", function () {
        // Send phx_join to mount the LiveView
        // Protocol: [join_ref, msg_ref, topic, event, payload]
        const joinRef = String(++msgRef);
        const topic = `lv:${tokens.phxId}`;
        const joinMsg = JSON.stringify([
          joinRef,
          joinRef,
          topic,
          "phx_join",
          {
            url: `${protocol}://${host}${page}`,
            params: {
              _csrf_token: tokens.csrfToken,
              _mounts: 0,
            },
            session: tokens.phxSession,
            static: tokens.phxStatic,
          },
        ]);
        socket.send(joinMsg);
      });

      socket.on("message", function (msg) {
        try {
          const parsed = JSON.parse(msg);
          // parsed = [join_ref, msg_ref, topic, event, payload]
          const event = parsed[3];
          const elapsed = Date.now() - wsStart;

          if (debug) {
            const payload = JSON.stringify(parsed[4] || {});
            console.log(
              `[ws ${elapsed}ms] event=${event} payload=${payload.length}b topic=${parsed[2]}`
            );
            // Show first 500 chars of payload to inspect content
            console.log(`  payload: ${payload.substring(0, 500)}`);
          }

          if (event === "phx_reply" && !gotJoinReply) {
            gotJoinReply = true;
            mountTime = elapsed;

            // Check if mount succeeded or errored
            const status = parsed[4] && parsed[4].status;
            if (status === "error") {
              mountError = true;
              if (debug) {
                console.log(`[ws] mount FAILED: ${JSON.stringify(parsed[4].response).substring(0, 200)}`);
              }
              socket.close();
              return;
            }

            // Mount succeeded
            wsMountDuration.add(mountTime);

            // Poll every 500ms: once diffs start arriving, close 2s after the last one.
            // If no diffs ever arrive, close after diffWait.
            let lastSeenDiffs = 0;
            let quietSince = Date.now();
            socket.setInterval(function () {
              const now = Date.now();
              if (totalDiffs > lastSeenDiffs) {
                // New diffs arrived — reset quiet timer
                lastSeenDiffs = totalDiffs;
                quietSince = now;
              } else if (gotFirstDiff && (now - quietSince) >= 2000) {
                // Diffs settled — no new ones for 2s
                if (debug) {
                  console.log(
                    `[ws] settled after ${totalDiffs} diffs, last at ${lastDiffTime}ms`
                  );
                }
                socket.close();
              } else if (!gotFirstDiff && (now - quietSince) >= diffWait) {
                // No diffs ever arrived within diffWait
                if (debug) {
                  console.log(
                    `[ws] no diff received after ${diffWait / 1000}s wait, closing`
                  );
                }
                socket.close();
              }
            }, 500);
          }

          if (event === "diff") {
            totalDiffs++;
            lastDiffTime = elapsed;

            if (!gotFirstDiff) {
              gotFirstDiff = true;
              firstDiffTime = elapsed;
              firstDiffDuration.add(firstDiffTime);
            }
          }
        } catch (_e) {
          // ignore parse errors
        }
      });

      // Hard timeout: close if mount never came
      socket.setTimeout(function () {
        if (debug) {
          console.log(`[ws] hard timeout (${hardTimeout / 1000}s), mount=${gotJoinReply} diff=${gotFirstDiff}`);
        }
        socket.close();
      }, hardTimeout);
    }
  );

  // Record metrics
  if (lastDiffTime !== null) {
    lastDiffDuration.add(lastDiffTime);
    // Full page = HTTP time + time to last diff (real user-perceived load)
    fullPageDuration.add(httpTime + lastDiffTime);
  } else if (mountTime !== null) {
    // No diffs — page loaded fully during mount
    fullPageDuration.add(httpTime + mountTime);
  } else {
    fullPageDuration.add(Date.now() - fullStart);
  }
  if (totalDiffs > 0) {
    diffCount.add(totalDiffs);
  }

  wsOk = check(wsRes, {
    "ws connected": (r) => r && r.status === 101,
  });
  wsConnectRate.add(wsOk ? 1 : 0);

  const success = httpOk && wsOk && gotJoinReply && !mountError;
  pageSuccessRate.add(success ? 1 : 0);

  if (!success) {
    pageErrors.add(1);
    if (debug && mountError) {
      console.log(`[result] mount error — HTTP ok, WS connected, but LiveView mount failed`);
    }
  }

  // Think time between iterations
  sleep(Math.random() * 2 + 1);
}

// --- Summary ---
export function handleSummary(data) {
  const fmt = (v) =>
    v !== null && v !== undefined ? v.toFixed(0) + "ms" : "N/A";
  const pct = (v) =>
    v !== null && v !== undefined ? (v * 100).toFixed(1) + "%" : "N/A";

  const m = (name, stat) => data.metrics[name]?.values[stat] ?? null;

  const stats = {
    test_info: {
      host: host,
      page: page,
      vus: vus,
      duration: duration,
      timestamp: new Date().toISOString(),
    },
    http_metrics: {
      requests_total: m("http_reqs", "count") || 0,
      ttfb_p50_ms: m("http_req_waiting", "med"),
      ttfb_p95_ms: m("http_req_waiting", "p(95)"),
      duration_p50_ms: m("http_req_duration", "med"),
      duration_p95_ms: m("http_req_duration", "p(95)"),
    },
    liveview_metrics: {
      http_p50_ms: m("bonfire_http_duration", "med"),
      http_p95_ms: m("bonfire_http_duration", "p(95)"),
      ws_mount_p50_ms: m("bonfire_ws_mount_duration", "med"),
      ws_mount_p95_ms: m("bonfire_ws_mount_duration", "p(95)"),
      first_diff_p50_ms: m("bonfire_first_diff_duration", "med"),
      first_diff_p95_ms: m("bonfire_first_diff_duration", "p(95)"),
      last_diff_p50_ms: m("bonfire_last_diff_duration", "med"),
      last_diff_p95_ms: m("bonfire_last_diff_duration", "p(95)"),
      diff_count_avg: m("bonfire_diff_count", "avg"),
      full_page_p50_ms: m("bonfire_full_page_duration", "med"),
      full_page_p95_ms: m("bonfire_full_page_duration", "p(95)"),
      success_rate: m("bonfire_page_success_rate", "rate"),
      ws_connect_rate: m("bonfire_ws_connect_rate", "rate"),
      errors: m("bonfire_page_errors", "count") || 0,
    },
  };

  return {
    stdout: `
================================================================================
                    Bonfire LiveView Load Test Results
================================================================================
  Host:             ${protocol}://${host}
  Page:             ${page}
  VUs:              ${vus}
  Duration:         ${duration}

  Phase 1 - HTTP (initial page load):
    p50:            ${fmt(stats.liveview_metrics.http_p50_ms)}
    p95:            ${fmt(stats.liveview_metrics.http_p95_ms)}

  Phase 2 - WebSocket (LiveView mount):
    Mount p50:      ${fmt(stats.liveview_metrics.ws_mount_p50_ms)}
    Mount p95:      ${fmt(stats.liveview_metrics.ws_mount_p95_ms)}

  Phase 3 - Async diffs (feed data):
    First p50:      ${fmt(stats.liveview_metrics.first_diff_p50_ms)}
    First p95:      ${fmt(stats.liveview_metrics.first_diff_p95_ms)}
    Last p50:       ${fmt(stats.liveview_metrics.last_diff_p50_ms)}
    Last p95:       ${fmt(stats.liveview_metrics.last_diff_p95_ms)}
    Avg diffs:      ${stats.liveview_metrics.diff_count_avg !== null ? stats.liveview_metrics.diff_count_avg.toFixed(0) : "N/A"}

  Full Page Lifecycle (HTTP + last diff settled):
    p50:            ${fmt(stats.liveview_metrics.full_page_p50_ms)}
    p95:            ${fmt(stats.liveview_metrics.full_page_p95_ms)}

  Reliability:
    Page Success:   ${pct(stats.liveview_metrics.success_rate)}
    WS Connect:     ${pct(stats.liveview_metrics.ws_connect_rate)}
    Errors:         ${stats.liveview_metrics.errors}

  Interpretation:
    Full Page p95 < 2s   = Excellent
    Full Page p95 2-5s   = Good
    Full Page p95 5-10s  = Degraded
    Full Page p95 > 10s  = System stressed
================================================================================
`,
    "benchmarks/output/k6_liveview_results.json": JSON.stringify(
      stats,
      null,
      2
    ),
  };
}
