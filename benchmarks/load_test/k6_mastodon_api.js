// Bonfire Load Test for k6 — Mastodon-compatible API
//
// Simulates realistic Mastodon client behaviour: fetching timelines, drilling
// into statuses, interacting (favourite, boost, bookmark), viewing profiles,
// paginating, and posting — with per-VU auth for multi-user testing.
//
// Usage:
//   k6 run -e TOKEN="your_token" benchmarks/load_test/k6_mastodon_api.js
//
// Options:
//   HOST       - Target host (default: localhost:4000)
//   TOKEN      - OAuth Bearer token (single-user mode)
//   COOKIE     - Session cookie value (single-user alternative)
//   TOKENS     - Comma-separated tokens for multi-user testing
//   HTTPS      - Set to "1" for https (default: http)
//   VUS        - Number of concurrent users (default: 50)
//   DURATION   - Test duration (default: 60s)
//   SCENARIO   - "read", "mixed", or "write" (default: mixed)
//   POST_VIS   - Visibility for posted statuses: "direct", "public", "unlisted",
//                "private" (default: direct — safe for load testing)
//
// Multi-user testing:
//   Pass multiple tokens so each VU gets its own identity. This tests per-user
//   cache behaviour, different social graphs, and realistic DB query patterns.
//
//   k6 run -e TOKENS="tok1,tok2,tok3" -e VUS=30 benchmarks/load_test/k6_mastodon_api.js
//
// Examples:
//   k6 run -e TOKEN="..." -e VUS=50 benchmarks/load_test/k6_mastodon_api.js
//   k6 run -e TOKENS="tok1,tok2,tok3" -e SCENARIO=read -e VUS=30 -e DURATION=2m benchmarks/load_test/k6_mastodon_api.js
//   k6 run -e TOKEN="..." -e SCENARIO=write -e POST_VIS=public -e VUS=10 benchmarks/load_test/k6_mastodon_api.js

import http from "k6/http";
import { check, sleep, group } from "k6";
import { Trend, Rate, Counter } from "k6/metrics";
// ── Custom metrics ──────────────────────────────────────────────────────────

const timelineDuration = new Trend("masto_timeline_duration", true);
const timelineSuccess = new Rate("masto_timeline_success");

const paginationDuration = new Trend("masto_pagination_duration", true);
const paginationSuccess = new Rate("masto_pagination_success");

const statusViewDuration = new Trend("masto_status_view_duration", true);
const statusViewSuccess = new Rate("masto_status_view_success");

const contextDuration = new Trend("masto_context_duration", true);
const contextSuccess = new Rate("masto_context_success");

const profileDuration = new Trend("masto_profile_duration", true);
const profileSuccess = new Rate("masto_profile_success");

const interactionDuration = new Trend("masto_interaction_duration", true);
const interactionSuccess = new Rate("masto_interaction_success");

const notificationsDuration = new Trend("masto_notifications_duration", true);
const notificationsSuccess = new Rate("masto_notifications_success");

const statusPostDuration = new Trend("masto_status_post_duration", true);
const statusPostSuccess = new Rate("masto_status_post_success");

const searchDuration = new Trend("masto_search_duration", true);
const searchSuccess = new Rate("masto_search_success");

const verifyCredsDuration = new Trend("masto_verify_creds_duration", true);
const verifyCredsSuccess = new Rate("masto_verify_creds_success");

const apiErrors = new Counter("masto_api_errors");

// ── Config from environment ─────────────────────────────────────────────────

const host = __ENV.HOST || "localhost:4000";
const isHttps = __ENV.HTTPS === "1";
const protocol = isHttps ? "https" : "http";
const baseUrl = `${protocol}://${host}`;
const vus = parseInt(__ENV.VUS || "50");
const duration = __ENV.DURATION || "60s";
const scenario = __ENV.SCENARIO || "mixed";
const postVisibility = __ENV.POST_VIS || "direct";

// Multi-user token pool: TOKENS env (comma-separated) or single TOKEN/COOKIE
const tokenPool = (() => {
  if (__ENV.TOKENS) {
    return __ENV.TOKENS.split(",").map((t) => t.trim()).filter(Boolean);
  }
  return [];
})();
const singleToken = __ENV.TOKEN;
const singleCookie = __ENV.COOKIE;

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
    masto_timeline_success: ["rate>0.95"],
    masto_verify_creds_success: ["rate>0.95"],
  },
};

// ── Auth helpers ─────────────────────────────────────────────────────────────

// Each VU gets a deterministic token from the pool (or falls back to single)
function vuAuth() {
  if (tokenPool.length > 0) {
    const tok = tokenPool[__VU % tokenPool.length];
    return { type: "bearer", value: tok };
  }
  if (singleToken) return { type: "bearer", value: singleToken };
  if (singleCookie) return { type: "cookie", value: singleCookie };
  return null;
}

function authParams(extra) {
  const auth = vuAuth();
  const params = {
    headers: { Accept: "application/json" },
    ...(extra || {}),
  };

  if (auth && auth.type === "bearer") {
    params.headers["Authorization"] = `Bearer ${auth.value}`;
  } else if (auth && auth.type === "cookie") {
    params.cookies = { _bonfire_key: auth.value };
  }
  return params;
}

function authParamsJson(extra) {
  const params = authParams(extra);
  params.headers["Content-Type"] = "application/json";
  return params;
}

// ── Response helpers ────────────────────────────────────────────────────────

function jsonBody(res) {
  try {
    return res.json();
  } catch (_) {
    return null;
  }
}

function pickRandom(arr) {
  if (!arr || arr.length === 0) return null;
  return arr[Math.floor(Math.random() * arr.length)];
}

// ── API calls ────────────────────────────────────────────────────────────────

function verifyCredentials() {
  const start = Date.now();
  const res = http.get(
    `${baseUrl}/api/v1/accounts/verify_credentials`,
    authParams({ tags: { name: "verify_credentials" } })
  );
  verifyCredsDuration.add(Date.now() - start);

  const ok = check(res, {
    "verify_credentials 200": (r) => r.status === 200,
    "verify_credentials has id": (r) => !!jsonBody(r)?.id,
  });
  verifyCredsSuccess.add(ok ? 1 : 0);
  if (!ok) apiErrors.add(1);
  return jsonBody(res);
}

// Fetch a timeline and return parsed statuses array
function getTimeline(type) {
  const paths = {
    home: "/api/v1/timelines/home?limit=20",
    public: "/api/v1/timelines/public?limit=20",
    local: "/api/v1/timelines/local?limit=20",
  };

  const start = Date.now();
  const res = http.get(
    `${baseUrl}${paths[type] || paths.home}`,
    authParams({ tags: { name: `timeline_${type}` } })
  );
  timelineDuration.add(Date.now() - start);

  const body = jsonBody(res);
  const ok = check(res, {
    [`${type} timeline 200`]: (r) => r.status === 200,
    [`${type} timeline is array`]: () => Array.isArray(body),
  });
  timelineSuccess.add(ok ? 1 : 0);
  if (!ok) apiErrors.add(1);

  return { statuses: Array.isArray(body) ? body : [], res };
}

// Paginate: fetch next page using max_id from last status
function paginateTimeline(type, statuses) {
  if (!statuses || statuses.length === 0) return [];

  const lastId = statuses[statuses.length - 1]?.id;
  if (!lastId) return [];

  const paths = {
    home: "/api/v1/timelines/home",
    public: "/api/v1/timelines/public",
    local: "/api/v1/timelines/local",
  };

  const start = Date.now();
  const res = http.get(
    `${baseUrl}${paths[type] || paths.home}?limit=20&max_id=${lastId}`,
    authParams({ tags: { name: `timeline_${type}_page2` } })
  );
  paginationDuration.add(Date.now() - start);

  const body = jsonBody(res);
  const ok = check(res, {
    "pagination 200": (r) => r.status === 200,
    "pagination is array": () => Array.isArray(body),
  });
  paginationSuccess.add(ok ? 1 : 0);
  if (!ok) apiErrors.add(1);

  return Array.isArray(body) ? body : [];
}

// View a single status
function viewStatus(statusId) {
  const start = Date.now();
  const res = http.get(
    `${baseUrl}/api/v1/statuses/${statusId}`,
    authParams({ tags: { name: "status_view" } })
  );
  statusViewDuration.add(Date.now() - start);

  const ok = check(res, {
    "status view 200": (r) => r.status === 200,
    "status view has id": (r) => !!jsonBody(r)?.id,
  });
  statusViewSuccess.add(ok ? 1 : 0);
  if (!ok) apiErrors.add(1);
  return jsonBody(res);
}

// Get thread context for a status
function getContext(statusId) {
  const start = Date.now();
  const res = http.get(
    `${baseUrl}/api/v1/statuses/${statusId}/context`,
    authParams({ tags: { name: "status_context" } })
  );
  contextDuration.add(Date.now() - start);

  const body = jsonBody(res);
  const ok = check(res, {
    "context 200": (r) => r.status === 200,
    "context has ancestors": () => Array.isArray(body?.ancestors),
  });
  contextSuccess.add(ok ? 1 : 0);
  if (!ok) apiErrors.add(1);
  return body;
}

// View an account profile + their recent statuses
function viewProfile(accountId) {
  const start = Date.now();
  const res = http.get(
    `${baseUrl}/api/v1/accounts/${accountId}`,
    authParams({ tags: { name: "profile_view" } })
  );
  profileDuration.add(Date.now() - start);

  const ok = check(res, {
    "profile 200": (r) => r.status === 200,
    "profile has username": (r) => !!jsonBody(r)?.username,
  });
  profileSuccess.add(ok ? 1 : 0);
  if (!ok) apiErrors.add(1);

  // Also fetch their statuses (like clicking into a profile)
  sleep(0.2);
  const statusRes = http.get(
    `${baseUrl}/api/v1/accounts/${accountId}/statuses?limit=10`,
    authParams({ tags: { name: "profile_statuses" } })
  );
  check(statusRes, { "profile statuses 200": (r) => r.status === 200 });

  return jsonBody(res);
}

// Favourite or unfavourite a status
function favouriteStatus(statusId) {
  const start = Date.now();
  const res = http.post(
    `${baseUrl}/api/v1/statuses/${statusId}/favourite`,
    null,
    authParams({ tags: { name: "favourite" } })
  );
  interactionDuration.add(Date.now() - start);

  const ok = check(res, {
    "favourite 200": (r) => r.status === 200,
  });
  interactionSuccess.add(ok ? 1 : 0);
  if (!ok) apiErrors.add(1);

  // Clean up: unfavourite so we don't accumulate state
  sleep(0.2);
  http.post(
    `${baseUrl}/api/v1/statuses/${statusId}/unfavourite`,
    null,
    authParams({ tags: { name: "unfavourite" } })
  );
}

// Reblog / unreblog a status
function reblogStatus(statusId) {
  const start = Date.now();
  const res = http.post(
    `${baseUrl}/api/v1/statuses/${statusId}/reblog`,
    null,
    authParams({ tags: { name: "reblog" } })
  );
  interactionDuration.add(Date.now() - start);

  const ok = check(res, {
    "reblog 200": (r) => r.status === 200,
  });
  interactionSuccess.add(ok ? 1 : 0);
  if (!ok) apiErrors.add(1);

  sleep(0.2);
  http.post(
    `${baseUrl}/api/v1/statuses/${statusId}/unreblog`,
    null,
    authParams({ tags: { name: "unreblog" } })
  );
}

// Bookmark / unbookmark a status
function bookmarkStatus(statusId) {
  const start = Date.now();
  const res = http.post(
    `${baseUrl}/api/v1/statuses/${statusId}/bookmark`,
    null,
    authParams({ tags: { name: "bookmark" } })
  );
  interactionDuration.add(Date.now() - start);

  const ok = check(res, {
    "bookmark 200": (r) => r.status === 200,
  });
  interactionSuccess.add(ok ? 1 : 0);
  if (!ok) apiErrors.add(1);

  sleep(0.2);
  http.post(
    `${baseUrl}/api/v1/statuses/${statusId}/unbookmark`,
    null,
    authParams({ tags: { name: "unbookmark" } })
  );
}

function getNotifications() {
  const start = Date.now();
  const res = http.get(
    `${baseUrl}/api/v1/notifications?limit=15`,
    authParams({ tags: { name: "notifications" } })
  );
  notificationsDuration.add(Date.now() - start);

  const body = jsonBody(res);
  const ok = check(res, {
    "notifications 200": (r) => r.status === 200,
    "notifications is array": () => Array.isArray(body),
  });
  notificationsSuccess.add(ok ? 1 : 0);
  if (!ok) apiErrors.add(1);
  return Array.isArray(body) ? body : [];
}

function postStatus() {
  const payload = JSON.stringify({
    status: `Load test ${Date.now()}-${__VU} #loadtest`,
    visibility: postVisibility,
  });

  const start = Date.now();
  const res = http.post(
    `${baseUrl}/api/v1/statuses`,
    payload,
    authParamsJson({ tags: { name: "post_status" } })
  );
  statusPostDuration.add(Date.now() - start);

  const body = jsonBody(res);
  const ok = check(res, {
    "post status 200": (r) => r.status === 200,
    "post status has id": () => !!body?.id,
  });
  statusPostSuccess.add(ok ? 1 : 0);
  if (!ok) apiErrors.add(1);
  return body;
}

function search(query) {
  const start = Date.now();
  const res = http.get(
    `${baseUrl}/api/v2/search?q=${encodeURIComponent(query)}&limit=5`,
    authParams({ tags: { name: "search" } })
  );
  searchDuration.add(Date.now() - start);

  const body = jsonBody(res);
  const ok = check(res, {
    "search 200": (r) => r.status === 200,
    "search has accounts": () => Array.isArray(body?.accounts),
  });
  searchSuccess.add(ok ? 1 : 0);
  if (!ok) apiErrors.add(1);
  return body;
}

function getConversations() {
  const res = http.get(
    `${baseUrl}/api/v1/conversations`,
    authParams({ tags: { name: "conversations" } })
  );
  check(res, { "conversations 200": (r) => r.status === 200 });
}

function getFavourites() {
  const res = http.get(
    `${baseUrl}/api/v1/favourites`,
    authParams({ tags: { name: "favourites" } })
  );
  check(res, { "favourites 200": (r) => r.status === 200 });
}

function getBookmarks() {
  const res = http.get(
    `${baseUrl}/api/v1/bookmarks`,
    authParams({ tags: { name: "bookmarks" } })
  );
  check(res, { "bookmarks 200": (r) => r.status === 200 });
}

// ── Scenarios ────────────────────────────────────────────────────────────────

// Simulates a Mastodon client session: open app → browse timeline → tap into
// a post → view thread → check who posted → maybe paginate for more
function readScenario() {
  group("read_flow", function () {
    // 1. App startup: verify who we are
    verifyCredentials();
    sleep(0.3);

    // 2. Load a timeline
    const tlType = pickRandom(["home", "home", "home", "public", "local"]);
    const { statuses } = getTimeline(tlType);
    sleep(0.5);

    // 3. Drill into a random status → view it + its thread
    const status = pickRandom(statuses);
    if (status) {
      viewStatus(status.id);
      sleep(0.3);

      getContext(status.id);
      sleep(0.3);

      // 4. View the author's profile
      if (status.account?.id) {
        viewProfile(status.account.id);
        sleep(0.3);
      }
    }

    // 5. Paginate: scroll down for more posts (40% chance)
    if (Math.random() < 0.4 && statuses.length > 0) {
      paginateTimeline(tlType, statuses);
      sleep(0.3);
    }

    // 6. Check notifications
    getNotifications();
    sleep(0.3);

    // 7. Occasionally check secondary views
    if (Math.random() < 0.2) getBookmarks();
    if (Math.random() < 0.15) getConversations();
    if (Math.random() < 0.1) getFavourites();
  });
}

// Simulates mixed usage: reading + interactions + occasional posting
function mixedScenario() {
  group("mixed_flow", function () {
    // 1. App startup
    verifyCredentials();
    sleep(0.3);

    // 2. Load home timeline
    const { statuses } = getTimeline("home");
    sleep(0.5);

    // 3. Interact with a random status from the timeline
    const status = pickRandom(statuses);
    if (status) {
      // View the full status
      viewStatus(status.id);
      sleep(0.2);

      // Interact: favourite (30%), reblog (10%), bookmark (15%)
      const roll = Math.random();
      if (roll < 0.30) {
        favouriteStatus(status.id);
      } else if (roll < 0.40) {
        reblogStatus(status.id);
      } else if (roll < 0.55) {
        bookmarkStatus(status.id);
      }
      sleep(0.3);

      // View thread (40% chance)
      if (Math.random() < 0.4) {
        getContext(status.id);
        sleep(0.2);
      }

      // View author profile (25% chance)
      if (Math.random() < 0.25 && status.account?.id) {
        viewProfile(status.account.id);
        sleep(0.2);
      }
    }

    // 4. Paginate (30% chance)
    if (Math.random() < 0.3 && statuses.length > 0) {
      paginateTimeline("home", statuses);
      sleep(0.3);
    }

    // 5. Check notifications
    getNotifications();
    sleep(0.3);

    // 6. Post a status (15% chance)
    if (Math.random() < 0.15) {
      postStatus();
      sleep(0.3);
    }

    // 7. Search (10% chance)
    if (Math.random() < 0.10) {
      search("bonfire");
      sleep(0.2);
    }
  });
}

// Simulates write-heavy usage: post, interact, check results
function writeScenario() {
  group("write_flow", function () {
    verifyCredentials();
    sleep(0.2);

    // 1. Post a status
    const posted = postStatus();
    sleep(0.5);

    // 2. If the post succeeded, view it back + its context
    if (posted?.id) {
      viewStatus(posted.id);
      sleep(0.3);

      getContext(posted.id);
      sleep(0.2);
    }

    // 3. Load timeline and interact with existing content
    const { statuses } = getTimeline("home");
    sleep(0.3);

    const status = pickRandom(statuses);
    if (status) {
      favouriteStatus(status.id);
      sleep(0.2);

      if (Math.random() < 0.3) {
        reblogStatus(status.id);
        sleep(0.2);
      }
    }

    // 4. Search
    if (Math.random() < 0.3) {
      search("loadtest");
      sleep(0.2);
    }

    // 5. Notifications
    getNotifications();
  });
}

// ── Setup & Main ─────────────────────────────────────────────────────────────

export function setup() {
  const hasAuth = tokenPool.length > 0 || singleToken || singleCookie;
  if (!hasAuth) {
    console.error(
      "Auth required. Provide one of:\n" +
        "  -e TOKEN=\"...\"           Single OAuth Bearer token\n" +
        "  -e COOKIE=\"...\"          Single session cookie (_bonfire_key)\n" +
        "  -e TOKENS=\"tok1,tok2\"    Multiple tokens for multi-user testing"
    );
    return { error: "no_auth" };
  }

  // Validate first token/cookie
  const auth = tokenPool.length > 0
    ? { type: "bearer", value: tokenPool[0] }
    : singleToken
      ? { type: "bearer", value: singleToken }
      : { type: "cookie", value: singleCookie };

  const params = { headers: { Accept: "application/json" } };
  if (auth.type === "bearer") {
    params.headers["Authorization"] = `Bearer ${auth.value}`;
  } else {
    params.cookies = { _bonfire_key: auth.value };
  }

  const testRes = http.get(
    `${baseUrl}/api/v1/accounts/verify_credentials`,
    params
  );

  if (testRes.status !== 200) {
    console.error(`Setup failed: status ${testRes.status}`);
    try { console.error(`Response: ${testRes.body}`); } catch (_) {}
    return { error: "auth_failed", status: testRes.status };
  }

  const me = jsonBody(testRes);
  const userCount = tokenPool.length || 1;

  console.log(`\n=== Bonfire Mastodon API Load Test ===`);
  console.log(`Host:       ${baseUrl}`);
  console.log(`Auth:       ${auth.type === "bearer" ? "Bearer token" : "Cookie"}`);
  console.log(`Users:      ${userCount}${userCount === 1 ? " (single-user — consider TOKENS for realistic testing)" : ""}`);
  console.log(`First user: ${me?.username || me?.acct || "unknown"}`);
  console.log(`VUs:        ${vus}`);
  console.log(`Duration:   ${duration}`);
  console.log(`Scenario:   ${scenario}`);
  console.log(`Post vis:   ${postVisibility}`);
  console.log(`\nMonitor:    ${baseUrl}/admin/system`);
  console.log(``);

  return { ok: true };
}

export default function (data) {
  if (data.error) {
    sleep(1);
    return;
  }

  switch (scenario) {
    case "read":
      readScenario();
      break;
    case "write":
      writeScenario();
      break;
    case "mixed":
    default:
      mixedScenario();
      break;
  }

  // Think time between iterations (1–3s)
  sleep(Math.random() * 2 + 1);
}

// ── Summary ──────────────────────────────────────────────────────────────────

export function handleSummary(data) {
  const fmt = (v) =>
    v !== null && v !== undefined ? v.toFixed(0) + "ms" : "N/A";
  const pct = (v) =>
    v !== null && v !== undefined ? (v * 100).toFixed(1) + "%" : "N/A";

  const m = data.metrics;

  const stats = {
    test_info: {
      host: host,
      vus: vus,
      duration: duration,
      scenario: scenario,
      post_visibility: postVisibility,
      user_count: tokenPool.length || 1,
      timestamp: new Date().toISOString(),
    },
    http_metrics: {
      requests_total: m.http_reqs?.values.count || 0,
      ttfb_p50_ms: m.http_req_waiting?.values.med ?? null,
      ttfb_p90_ms: m.http_req_waiting?.values["p(90)"] ?? null,
      ttfb_p95_ms: m.http_req_waiting?.values["p(95)"] ?? null,
      duration_p50_ms: m.http_req_duration?.values.med ?? null,
      duration_p90_ms: m.http_req_duration?.values["p(90)"] ?? null,
      duration_p95_ms: m.http_req_duration?.values["p(95)"] ?? null,
    },
    api_metrics: {
      timeline_p50_ms: m.masto_timeline_duration?.values.med ?? null,
      timeline_p95_ms: m.masto_timeline_duration?.values["p(95)"] ?? null,
      timeline_success: m.masto_timeline_success?.values["rate"] ?? null,
      pagination_p95_ms: m.masto_pagination_duration?.values["p(95)"] ?? null,
      status_view_p95_ms: m.masto_status_view_duration?.values["p(95)"] ?? null,
      context_p95_ms: m.masto_context_duration?.values["p(95)"] ?? null,
      profile_p95_ms: m.masto_profile_duration?.values["p(95)"] ?? null,
      interaction_p95_ms: m.masto_interaction_duration?.values["p(95)"] ?? null,
      notifications_p95_ms: m.masto_notifications_duration?.values["p(95)"] ?? null,
      post_status_p95_ms: m.masto_status_post_duration?.values["p(95)"] ?? null,
      search_p95_ms: m.masto_search_duration?.values["p(95)"] ?? null,
      verify_creds_p95_ms: m.masto_verify_creds_duration?.values["p(95)"] ?? null,
      errors: m.masto_api_errors?.values.count || 0,
    },
  };

  return {
    stdout: `
================================================================================
                   Bonfire Mastodon API Load Test Results
================================================================================
  Host:             ${baseUrl}
  VUs:              ${vus}
  Duration:         ${duration}
  Scenario:         ${scenario}
  Post visibility:  ${postVisibility}
  Users:            ${stats.test_info.user_count}

  HTTP Metrics:
    Total Requests: ${stats.http_metrics.requests_total}
    TTFB p50:       ${fmt(stats.http_metrics.ttfb_p50_ms)}
    TTFB p90:       ${fmt(stats.http_metrics.ttfb_p90_ms)}
    TTFB p95:       ${fmt(stats.http_metrics.ttfb_p95_ms)}
    Duration p95:   ${fmt(stats.http_metrics.duration_p95_ms)}

  API Metrics (p95):
    Timelines:      ${fmt(stats.api_metrics.timeline_p95_ms)}   (success: ${pct(stats.api_metrics.timeline_success)})
    Pagination:     ${fmt(stats.api_metrics.pagination_p95_ms)}
    Status view:    ${fmt(stats.api_metrics.status_view_p95_ms)}
    Thread context: ${fmt(stats.api_metrics.context_p95_ms)}
    Profile view:   ${fmt(stats.api_metrics.profile_p95_ms)}
    Interactions:   ${fmt(stats.api_metrics.interaction_p95_ms)}
    Notifications:  ${fmt(stats.api_metrics.notifications_p95_ms)}
    Post status:    ${fmt(stats.api_metrics.post_status_p95_ms)}
    Search:         ${fmt(stats.api_metrics.search_p95_ms)}
    Verify creds:   ${fmt(stats.api_metrics.verify_creds_p95_ms)}
    Total Errors:   ${stats.api_metrics.errors}

  Interpretation:
    TTFB p95 < 500ms    = Good
    TTFB p95 500-2000ms = Moderate load
    TTFB p95 > 2000ms   = System stressed
================================================================================
`,
    "benchmarks/output/k6_mastodon_api_results.json": JSON.stringify(
      stats,
      null,
      2
    ),
  };
}
