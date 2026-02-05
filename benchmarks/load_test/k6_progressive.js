// Bonfire Load Test for k6 (HTTP-only)
//
// Measures HTTP response times and success rates at a fixed concurrency level.
//
// Usage:
//   k6 run -e COOKIE="your_cookie" -e VUS=50 benchmarks/load_test/k6_progressive.js
//
// Options:
//   HOST     - Target host (default: localhost:4000)
//   COOKIE   - Session cookie value (required)
//   HTTPS    - Set to "1" for https (default: http)
//   VUS      - Number of concurrent users (default: 50)
//   DURATION - Test duration (default: 60s)
//
// Examples:
//   k6 run -e COOKIE="..." -e VUS=50 -e DURATION=60s benchmarks/load_test/k6_progressive.js
//   k6 run -e COOKIE="..." -e VUS=100 -e DURATION=2m benchmarks/load_test/k6_progressive.js
//   k6 run -e COOKIE="..." -e VUS=500 -e DURATION=5m -e HOST=test.example.com -e HTTPS=1 benchmarks/load_test/k6_progressive.js

import http from "k6/http";
import { check, sleep } from "k6";
import { Trend, Rate, Counter } from "k6/metrics";

// Custom metrics
const feedLoadDuration = new Trend("bonfire_feed_load_duration", true);
const feedSuccessRate = new Rate("bonfire_feed_success_rate");
const feedErrors = new Counter("bonfire_feed_errors");

// Config from environment
const host = __ENV.HOST || "localhost:4000";
const cookie = __ENV.COOKIE;
const https = __ENV.HTTPS === "1";
const protocol = https ? "https" : "http";
const vus = parseInt(__ENV.VUS || "50");
const duration = __ENV.DURATION || "60s";

export const options = {
  scenarios: {
    constant_load: {
      executor: "constant-vus",
      vus: vus,
      duration: duration,
    },
  },
  thresholds: {
    http_req_duration: ["p(95)<5000"],
    bonfire_feed_success_rate: ["rate>0.95"],
  },
};

export function setup() {
  if (!cookie) {
    console.error(
      "COOKIE env var required. Get it from browser DevTools (copy _bonfire_key value)."
    );
    return { error: "no_cookie" };
  }

  // Test connection
  const testRes = http.get(`${protocol}://${host}/feed/explore`, {
    cookies: { _bonfire_key: cookie },
  });

  if (testRes.status !== 200) {
    console.error(`Setup failed: status ${testRes.status}`);
    return { error: "connection_failed", status: testRes.status };
  }

  console.log(`\n=== Bonfire Load Test ===`);
  console.log(`Host: ${protocol}://${host}`);
  console.log(`VUs: ${vus}`);
  console.log(`Duration: ${duration}`);
  console.log(`\nMonitor: ${protocol}://${host}/admin/system`);
  console.log(`\n`);

  return { ok: true };
}

export default function (data) {
  if (data.error) {
    sleep(1);
    return;
  }

  // Load feed/explore page
  const startFeed = Date.now();
  const feedRes = http.get(`${protocol}://${host}/feed/explore`, {
    cookies: { _bonfire_key: cookie },
    tags: { name: "feed_explore" },
  });
  const feedDuration = Date.now() - startFeed;
  feedLoadDuration.add(feedDuration);

  const feedOk = check(feedRes, {
    "feed status 200": (r) => r.status === 200,
    "feed is liveview": (r) => r.body && r.body.includes("phx-"),
  });

  feedSuccessRate.add(feedOk ? 1 : 0);

  if (!feedOk) {
    feedErrors.add(1);
  }

  // Random delay between requests (1-3 seconds)
  sleep(Math.random() * 2 + 1);
}

export function handleSummary(data) {
  const fmt = (v) => (v !== null && v !== undefined ? v.toFixed(0) + "ms" : "N/A");
  const pct = (v) => (v !== null && v !== undefined ? (v * 100).toFixed(1) + "%" : "N/A");

  const stats = {
    test_info: {
      host: host,
      vus: vus,
      duration: duration,
      timestamp: new Date().toISOString(),
    },
    http_metrics: {
      requests_total: data.metrics.http_reqs?.values.count || 0,
      ttfb_p50_ms: data.metrics.http_req_waiting?.values.med ?? null,
      ttfb_p90_ms: data.metrics.http_req_waiting?.values["p(90)"] ?? null,
      ttfb_p95_ms: data.metrics.http_req_waiting?.values["p(95)"] ?? null,
      duration_p50_ms: data.metrics.http_req_duration?.values.med ?? null,
      duration_p90_ms: data.metrics.http_req_duration?.values["p(90)"] ?? null,
      duration_p95_ms: data.metrics.http_req_duration?.values["p(95)"] ?? null,
    },
    feed_metrics: {
      load_p50_ms: data.metrics.bonfire_feed_load_duration?.values.med ?? null,
      load_p90_ms: data.metrics.bonfire_feed_load_duration?.values["p(90)"] ?? null,
      load_p95_ms: data.metrics.bonfire_feed_load_duration?.values["p(95)"] ?? null,
      success_rate: data.metrics.bonfire_feed_success_rate?.values["rate"] || null,
      errors: data.metrics.bonfire_feed_errors?.values.count || 0,
    },
  };

  return {
    stdout: `
================================================================================
                         Bonfire Load Test Results
================================================================================
  Host:             ${protocol}://${host}
  VUs:              ${vus}
  Duration:         ${duration}

  HTTP Metrics:
    Total Requests: ${stats.http_metrics.requests_total}
    TTFB p50:       ${fmt(stats.http_metrics.ttfb_p50_ms)}
    TTFB p90:       ${fmt(stats.http_metrics.ttfb_p90_ms)}
    TTFB p95:       ${fmt(stats.http_metrics.ttfb_p95_ms)}
    Duration p95:   ${fmt(stats.http_metrics.duration_p95_ms)}

  Feed Metrics:
    Load p50:       ${fmt(stats.feed_metrics.load_p50_ms)}
    Load p90:       ${fmt(stats.feed_metrics.load_p90_ms)}
    Load p95:       ${fmt(stats.feed_metrics.load_p95_ms)}
    Success Rate:   ${pct(stats.feed_metrics.success_rate)}
    Errors:         ${stats.feed_metrics.errors}

  Interpretation:
    TTFB p95 < 500ms  = Good
    TTFB p95 500-2000ms = Moderate load
    TTFB p95 > 2000ms = System stressed
================================================================================
`,
    "benchmarks/output/k6_results.json": JSON.stringify(stats, null, 2),
  };
}
