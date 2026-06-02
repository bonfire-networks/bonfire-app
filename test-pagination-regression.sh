#!/usr/bin/env bash
set -euo pipefail

script_path="$(readlink -f "${BASH_SOURCE[0]}")"

cd "$(dirname "$script_path")"

if [[ "${BONFIRE_PAGINATION_LOCK_HELD:-0}" != "1" && "${BONFIRE_PAGINATION_SKIP_LOCK:-0}" != "1" ]]; then
  lock_file="${BONFIRE_PAGINATION_LOCK_FILE:-$PWD/.bonfire-pagination-regression.lock}"
  exec 9>"$lock_file"

  if command -v flock >/dev/null 2>&1; then
    lock_timeout="${BONFIRE_PAGINATION_LOCK_TIMEOUT_SECONDS:-600}"
    if ! flock -w "$lock_timeout" 9; then
      echo "Another pagination regression run is using this checkout. Lock file: $lock_file" >&2
      echo "Wait for it to finish, or set BONFIRE_PAGINATION_LOCK_FILE to isolate a separate checkout/database." >&2
      exit 75
    fi
    export BONFIRE_PAGINATION_LOCK_HELD=1
  else
    echo "Warning: flock is unavailable; do not run this script concurrently in the same checkout/database." >&2
  fi
fi

database_url_was_set=0
postgres_db_was_set=0

if [[ -v DATABASE_URL ]]; then
  database_url_was_set=1
  database_url="$DATABASE_URL"
else
  database_url="ecto://${POSTGRES_USER:-postgres}:${POSTGRES_PASSWORD:-postgres}@${POSTGRES_HOST:-localhost}:${POSTGRES_PORT:-5432}/${POSTGRES_DB:-bonfire_test}"
fi

if [[ -v POSTGRES_DB ]]; then
  postgres_db_was_set=1
fi

url_path="${database_url#*://}"
url_auth_host="${url_path%%/*}"
url_database="${url_path#*/}"
url_database="${url_database%%\?*}"
url_host_port="${url_auth_host##*@}"
url_host="${url_host_port%%:*}"
url_port=""
url_auth=""
url_user=""
url_password=""

if [[ "$url_host_port" == *:* ]]; then
  url_port="${url_host_port##*:}"
fi

if [[ "$url_auth_host" != "$url_host_port" ]]; then
  url_auth="${url_auth_host%@*}"
fi

if [[ -n "$url_auth" ]]; then
  if [[ "$url_auth" == *:* ]]; then
    url_user="${url_auth%%:*}"
    url_password="${url_auth#*:}"
  else
    url_user="$url_auth"
  fi
fi

if [[ "$database_url_was_set" == "1" && "$postgres_db_was_set" == "1" && "$POSTGRES_DB" != "$url_database" ]]; then
  echo "DATABASE_URL targets database '$url_database' but POSTGRES_DB is '$POSTGRES_DB'." >&2
  echo "Unset POSTGRES_DB or make it match DATABASE_URL before running the pagination regression script." >&2
  exit 64
fi

export DATABASE_URL="$database_url"
export POSTGRES_USER="${POSTGRES_USER:-${url_user:-postgres}}"
export POSTGRES_PASSWORD="${POSTGRES_PASSWORD:-${url_password:-postgres}}"
export POSTGRES_HOST="${POSTGRES_HOST:-${url_host:-localhost}}"
export POSTGRES_PORT="${POSTGRES_PORT:-${url_port:-5432}}"
export POSTGRES_DB="${POSTGRES_DB:-${url_database:-bonfire_test}}"
export DB_MIGRATE_INDEXES_CONCURRENTLY="${DB_MIGRATE_INDEXES_CONCURRENTLY:-false}"
export SECRET_KEY_BASE="aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
export SIGNING_SALT="bbbbbbbbbbbbbbbb"
export ENCRYPTION_SALT="cccccccccccccccc"
export MIX_ENV=test
export MIX_QUIET="${MIX_QUIET:-1}"
export DISABLE_LOG="${DISABLE_LOG:-true}"
export FLAVOUR=social
export WITH_DOCKER="${WITH_DOCKER:-no}"
export WITH_AI="${WITH_AI:-0}"
export TEST_WITH_MNEME="${TEST_WITH_MNEME:-no}"
export BONFIRE_LIGHTWEIGHT_TEST_SETUP=1
export BONFIRE_LIGHTWEIGHT_TEST_MIGRATE=1

if [[ "${BONFIRE_ALLOW_NON_TEST_DATABASE:-0}" != "1" && "$url_database" != *"_test"* ]]; then
  echo "Refusing to create/migrate DATABASE_URL target '$url_database' because it does not look like a test database." >&2
  echo "Set BONFIRE_ALLOW_NON_TEST_DATABASE=1 only for an intentional throwaway database." >&2
  exit 64
fi

if command -v pg_isready >/dev/null 2>&1 &&
  ! pg_isready -q -h "$POSTGRES_HOST" -p "$POSTGRES_PORT" -U "$POSTGRES_USER"; then
  echo "Postgres is not reachable at $POSTGRES_HOST:$POSTGRES_PORT for user $POSTGRES_USER." >&2
  echo "Set DATABASE_URL or POSTGRES_* to a running local test database." >&2
  exit 69
fi

run_mix() {
  if command -v mise >/dev/null 2>&1; then
    mise exec -- mix "$@"
  elif [ -x "$HOME/.local/bin/mise" ]; then
    "$HOME/.local/bin/mise" exec -- mix "$@"
  else
    mix "$@"
  fi
}

run_mix_with_timeout() {
  timeout_seconds="$1"
  shift

  if command -v timeout >/dev/null 2>&1; then
    if command -v mise >/dev/null 2>&1; then
      timeout --kill-after=30s --preserve-status "$timeout_seconds" mise exec -- mix "$@"
    elif [ -x "$HOME/.local/bin/mise" ]; then
      timeout --kill-after=30s --preserve-status "$timeout_seconds" "$HOME/.local/bin/mise" exec -- mix "$@"
    else
      timeout --kill-after=30s --preserve-status "$timeout_seconds" mix "$@"
    fi
  else
    echo "Warning: timeout is unavailable; benchmark will rely on its internal timing gates only." >&2
    run_mix "$@"
  fi
}

run_format_check() {
  run_mix format --check-formatted "${format_targets[@]}"
}

run_test() {
  run_mix test --force "$@" --trace
}

format_targets=(
  config/runtime.exs
  config/test.exs
  lib/mix/mixer.ex
  mix.exs
  benchmarks/classic_feed_benchmark.exs
  test/test_helper.exs
  test/support/lightweight_test_application.ex
  ../bonfire_common/lib/repo/test_instance_repo.ex
  ../bonfire_common/lib/runtime_config.ex
  ../bonfire_common/test/support/nebulex_cache_test.ex
  ../bonfire_data_social/lib/activity.ex
  ../bonfire_data_social/lib/feed_publish.ex
  ../bonfire_social/lib/feed_loader.ex
  ../bonfire_social/lib/runtime_config.ex
  ../bonfire_social/priv/repo/migrations/20260516000100_add_feed_publish_feed_id_id_index.exs
  ../bonfire_social/priv/repo/migrations/20260516000200_add_activity_feed_lookup_index.exs
  ../bonfire_social/test/feeds/feed_query_pagination_test.exs
  ../bonfire_ui_social/lib/benchmark.ex
  ../bonfire_ui_social/lib/live_handlers/feeds_live_handler.ex
  ../bonfire_ui_social/test/views/pagination/deferred_join_actual_cases_test.exs
  ../bonfire_ui_social/test/views/pagination/feed_load_more_remove_time_filter_test.exs
  ../bonfire_ui_social/test/views/pagination/feed_backend_benchmark_target_test.exs
  ../bonfire_ui_social/test/views/pagination/feed_full_preload_render_stress_test.exs
  ../bonfire_ui_social/test/views/pagination/feed_browser_js_time_limit_test.exs
  ../bonfire_ui_social/test/views/pagination/feed_auto_pagination_short_feed_test.exs
  ../bonfire_ui_social/test/views/pagination/load_more_context_attr_test.exs
  ../bonfire_ui_social/test/views/pagination/load_more_with_deferred_join.exs
)

case "${1:-all}" in
  format)
    unset MIX_TEST_ONLY
    run_format_check
    ;;
  backend)
    export MIX_TEST_ONLY=backend
    run_test ../bonfire_social/test/feeds/feed_query_pagination_test.exs
    ;;
  ui)
    export MIX_TEST_ONLY=ui
    run_test ../bonfire_ui_social/test/views/pagination/load_more_with_deferred_join.exs
    ;;
  ui-presets)
    export MIX_TEST_ONLY=ui
    run_test ../bonfire_ui_social/test/views/pagination/feed_presets_load_more_test.exs
    ;;
  ui-context)
    export MIX_TEST_ONLY=ui
    run_test ../bonfire_ui_social/test/views/pagination/load_more_context_attr_test.exs
    ;;
  ui-auto-short-feed)
    export MIX_TEST_ONLY=ui
    run_test ../bonfire_ui_social/test/views/pagination/feed_auto_pagination_short_feed_test.exs
    ;;
  ui-actual-cases)
    export MIX_TEST_ONLY=ui
    run_test ../bonfire_ui_social/test/views/pagination/deferred_join_actual_cases_test.exs
    ;;
  ui-time-limit)
    export MIX_TEST_ONLY=ui
    run_test ../bonfire_ui_social/test/views/pagination/feed_load_more_remove_time_filter_test.exs --only pagination_time_limit
    ;;
  ui-benchmark-target)
    export MIX_TEST_ONLY=ui
    run_test ../bonfire_ui_social/test/views/pagination/feed_backend_benchmark_target_test.exs
    ;;
  ui-full-preload-render-stress)
    export MIX_TEST_ONLY=ui
    export BONFIRE_FULL_RENDER_PAGE_LIMIT="${BONFIRE_FULL_RENDER_PAGE_LIMIT:-20}"
    export BONFIRE_FULL_RENDER_HIDDEN_MULTIPLIER="${BONFIRE_FULL_RENDER_HIDDEN_MULTIPLIER:-32}"
    export BONFIRE_FULL_RENDER_HIDDEN_EXTRA_ROWS="${BONFIRE_FULL_RENDER_HIDDEN_EXTRA_ROWS:-5}"
    export BONFIRE_FULL_PRELOAD_MAX_MS="${BONFIRE_FULL_PRELOAD_MAX_MS:-1000}"
    export BONFIRE_FULL_COMPONENT_RENDER_MAX_MS="${BONFIRE_FULL_COMPONENT_RENDER_MAX_MS:-3000}"
    export BONFIRE_FULL_INITIAL_RENDER_MAX_MS="${BONFIRE_FULL_INITIAL_RENDER_MAX_MS:-5000}"
    export BONFIRE_FULL_LOAD_MORE_RENDER_MAX_MS="${BONFIRE_FULL_LOAD_MORE_RENDER_MAX_MS:-3000}"
    export DB_OWNERSHIP_TIMEOUT="${DB_OWNERSHIP_TIMEOUT:-600000}"
    echo "Full preload/render stress: page_limit=$BONFIRE_FULL_RENDER_PAGE_LIMIT hidden_multiplier=$BONFIRE_FULL_RENDER_HIDDEN_MULTIPLIER hidden_extra_rows=$BONFIRE_FULL_RENDER_HIDDEN_EXTRA_ROWS preload_max_ms=$BONFIRE_FULL_PRELOAD_MAX_MS component_render_max_ms=$BONFIRE_FULL_COMPONENT_RENDER_MAX_MS initial_render_max_ms=$BONFIRE_FULL_INITIAL_RENDER_MAX_MS load_more_render_max_ms=$BONFIRE_FULL_LOAD_MORE_RENDER_MAX_MS"
    run_test ../bonfire_ui_social/test/views/pagination/feed_full_preload_render_stress_test.exs
    ;;
  ui-browser-js)
    export MIX_TEST_ONLY=ui
    export PHX_SERVER=yes
    export HOSTNAME="${HOSTNAME:-127.0.0.1}"
    export SERVER_PORT="${SERVER_PORT:-4011}"
    export PUBLIC_PORT="${PUBLIC_PORT:-$SERVER_PORT}"
    run_test ../bonfire_ui_social/test/views/pagination/feed_browser_js_time_limit_test.exs --only browser_js
    ;;
  classic-benchmark)
    unset MIX_TEST_ONLY
    run_mix run benchmarks/classic_feed_benchmark.exs
    ;;
  classic-benchmark-stress)
    unset MIX_TEST_ONLY
    stress_database_url="${BONFIRE_CLASSIC_STRESS_DATABASE_URL:-ecto://${POSTGRES_USER}:${POSTGRES_PASSWORD}@${POSTGRES_HOST}:${POSTGRES_PORT}/bonfire_test_classic_stress}"
    stress_url_path="${stress_database_url#*://}"
    stress_url_auth_host="${stress_url_path%%/*}"
    stress_database="${stress_url_path#*/}"
    stress_database="${stress_database%%\?*}"
    stress_host_port="${stress_url_auth_host##*@}"
    stress_host="${stress_host_port%%:*}"
    stress_port="$POSTGRES_PORT"
    stress_auth=""
    stress_user="$POSTGRES_USER"
    stress_password="$POSTGRES_PASSWORD"

    if [[ "$stress_host_port" == *:* ]]; then
      stress_port="${stress_host_port##*:}"
    fi

    if [[ "$stress_url_auth_host" != "$stress_host_port" ]]; then
      stress_auth="${stress_url_auth_host%@*}"
    fi

    if [[ -n "$stress_auth" ]]; then
      if [[ "$stress_auth" == *:* ]]; then
        stress_user="${stress_auth%%:*}"
        stress_password="${stress_auth#*:}"
      else
        stress_user="$stress_auth"
      fi
    fi

    if [[ "$stress_database" != *"_test"* ]]; then
      echo "Refusing to run stress benchmark against a database that does not look like a test database." >&2
      exit 64
    fi

    if [[ ! "$stress_database" =~ ^[A-Za-z0-9_.-]+$ ]]; then
      echo "Refusing stress database name with unsafe characters: $stress_database" >&2
      exit 64
    fi

    drop_stress_database() {
      if PGPASSWORD="$POSTGRES_PASSWORD" psql -h "$POSTGRES_HOST" -p "$POSTGRES_PORT" \
        -U "$POSTGRES_USER" -d postgres -AtqX -v ON_ERROR_STOP=1 \
        -c "select 1 from pg_database where datname = '$POSTGRES_DB'" | grep -qx 1; then
        PGPASSWORD="$POSTGRES_PASSWORD" dropdb --force \
          -h "$POSTGRES_HOST" -p "$POSTGRES_PORT" -U "$POSTGRES_USER" "$POSTGRES_DB"
      fi
    }

    export DATABASE_URL="$stress_database_url"
    export POSTGRES_USER="$stress_user"
    export POSTGRES_PASSWORD="$stress_password"
    export POSTGRES_HOST="${stress_host:-localhost}"
    export POSTGRES_PORT="$stress_port"
    export POSTGRES_DB="$stress_database"
    export BONFIRE_CLASSIC_FEED_ROWS="${BONFIRE_CLASSIC_FEED_ROWS:-1000000}"
    export BONFIRE_CLASSIC_EXACT_FEED_PUBLISH_ROWS="${BONFIRE_CLASSIC_EXACT_FEED_PUBLISH_ROWS:-$BONFIRE_CLASSIC_FEED_ROWS}"
    export BONFIRE_CLASSIC_LOCAL_EVERY="${BONFIRE_CLASSIC_LOCAL_EVERY:-493}"
    export BONFIRE_CLASSIC_HIDDEN_LOCAL_EVERY="${BONFIRE_CLASSIC_HIDDEN_LOCAL_EVERY:-23}"
    export BONFIRE_CLASSIC_HIDDEN_LOCAL_BURST_ROWS="${BONFIRE_CLASSIC_HIDDEN_LOCAL_BURST_ROWS:-5000}"
    export BONFIRE_CLASSIC_FETCHER_EVERY="${BONFIRE_CLASSIC_FETCHER_EVERY:-389}"
    export BONFIRE_CLASSIC_CHURN_ROWS="${BONFIRE_CLASSIC_CHURN_ROWS:-250000}"
    export BONFIRE_CLASSIC_VACUUM_AFTER_CHURN="${BONFIRE_CLASSIC_VACUUM_AFTER_CHURN:-1}"
    export BONFIRE_CLASSIC_VACUUM_AFTER_SEED="${BONFIRE_CLASSIC_VACUUM_AFTER_SEED:-1}"
    export BONFIRE_CLASSIC_SEED_BATCH="${BONFIRE_CLASSIC_SEED_BATCH:-25000}"
    export BONFIRE_CLASSIC_FAST_SEED="${BONFIRE_CLASSIC_FAST_SEED:-1}"
    export BONFIRE_CLASSIC_BENCH_WARMUP_RUNS="${BONFIRE_CLASSIC_BENCH_WARMUP_RUNS:-1}"
    export BONFIRE_CLASSIC_BENCH_ITERATIONS="${BONFIRE_CLASSIC_BENCH_ITERATIONS:-3}"
    export BONFIRE_CLASSIC_REQUIRED_PAGES="${BONFIRE_CLASSIC_REQUIRED_PAGES:-90}"
    export BONFIRE_CLASSIC_EXPLAIN_PAGE="${BONFIRE_CLASSIC_EXPLAIN_PAGE:-90}"
    export BONFIRE_CLASSIC_KEEP_ROWS=1
    export BONFIRE_CLASSIC_REQUIRE_TARGET_INDEX="${BONFIRE_CLASSIC_REQUIRE_TARGET_INDEX:-1}"
    export BONFIRE_CLASSIC_REQUIRE_NO_FEED_PUBLISH_SEQ_SCAN="${BONFIRE_CLASSIC_REQUIRE_NO_FEED_PUBLISH_SEQ_SCAN:-1}"
    export BONFIRE_CLASSIC_REQUIRE_NO_TEMP_BLOCKS="${BONFIRE_CLASSIC_REQUIRE_NO_TEMP_BLOCKS:-1}"
    export BONFIRE_CLASSIC_REQUIRE_FULL_PAGE="${BONFIRE_CLASSIC_REQUIRE_FULL_PAGE:-1}"
    export BONFIRE_CLASSIC_MIN_VISIBLE_LOCAL_ROWS="${BONFIRE_CLASSIC_MIN_VISIBLE_LOCAL_ROWS:-2000}"
    export BONFIRE_CLASSIC_MIN_HIDDEN_LOCAL_ROWS="${BONFIRE_CLASSIC_MIN_HIDDEN_LOCAL_ROWS:-40000}"
    export BONFIRE_CLASSIC_MAX_FEED_PUBLISH_ACTUAL_ROWS="${BONFIRE_CLASSIC_MAX_FEED_PUBLISH_ACTUAL_ROWS:-75000}"
    export BONFIRE_CLASSIC_MAX_FEED_PUBLISH_HEAP_FETCHES="${BONFIRE_CLASSIC_MAX_FEED_PUBLISH_HEAP_FETCHES:-1000}"
    export BONFIRE_CLASSIC_MAX_FEED_PUBLISH_ROWS_REMOVED_BY_FILTER="${BONFIRE_CLASSIC_MAX_FEED_PUBLISH_ROWS_REMOVED_BY_FILTER:-50000}"
    export BONFIRE_CLASSIC_MAX_FIRST_MS="${BONFIRE_CLASSIC_MAX_FIRST_MS:-222}"
    export BONFIRE_CLASSIC_MAX_P95_MS="${BONFIRE_CLASSIC_MAX_P95_MS:-222}"
    export BONFIRE_CLASSIC_MAX_PAGE_MS="${BONFIRE_CLASSIC_MAX_PAGE_MS:-222}"
    export BONFIRE_CLASSIC_MAX_PAGE_P95_MS="${BONFIRE_CLASSIC_MAX_PAGE_P95_MS:-222}"
    export BONFIRE_CLASSIC_BENCH_WORK_MEM="${BONFIRE_CLASSIC_BENCH_WORK_MEM:-4MB}"
    export BONFIRE_CLASSIC_BENCH_EFFECTIVE_CACHE_SIZE="${BONFIRE_CLASSIC_BENCH_EFFECTIVE_CACHE_SIZE:-128MB}"
    export BONFIRE_CLASSIC_BENCH_RANDOM_PAGE_COST="${BONFIRE_CLASSIC_BENCH_RANDOM_PAGE_COST:-4}"
    export BONFIRE_CLASSIC_STRESS_TIMEOUT_SECONDS="${BONFIRE_CLASSIC_STRESS_TIMEOUT_SECONDS:-1800}"
    export DB_QUERY_TIMEOUT="${DB_QUERY_TIMEOUT:-600000}"
    export DB_STATEMENT_TIMEOUT="${DB_STATEMENT_TIMEOUT:-0}"
    export DB_IDLE_TRANSACTION_TIMEOUT="${DB_IDLE_TRANSACTION_TIMEOUT:-600000}"
    export DB_POOL_TIMEOUT="${DB_POOL_TIMEOUT:-600000}"
    export DB_OWNERSHIP_TIMEOUT="${DB_OWNERSHIP_TIMEOUT:-600000}"
    drop_stress_database
    trap 'drop_stress_database' EXIT
    trap 'exit 130' INT
    trap 'exit 143' TERM
    stress_status=0
    run_mix_with_timeout "$BONFIRE_CLASSIC_STRESS_TIMEOUT_SECONDS" run benchmarks/classic_feed_benchmark.exs || stress_status=$?
    trap - EXIT INT TERM
    drop_stress_database
    exit "$stress_status"
    ;;
  classic-benchmark-local-heavy)
    export BONFIRE_CLASSIC_STRESS_DATABASE_URL="${BONFIRE_CLASSIC_LOCAL_HEAVY_DATABASE_URL:-ecto://${POSTGRES_USER}:${POSTGRES_PASSWORD}@${POSTGRES_HOST}:${POSTGRES_PORT}/bonfire_test_classic_local_heavy}"
    export BONFIRE_CLASSIC_FEED_ROWS="${BONFIRE_CLASSIC_FEED_ROWS:-1000000}"
    export BONFIRE_CLASSIC_EXACT_FEED_PUBLISH_ROWS="${BONFIRE_CLASSIC_EXACT_FEED_PUBLISH_ROWS:-$BONFIRE_CLASSIC_FEED_ROWS}"
    export BONFIRE_CLASSIC_LOCAL_EVERY="${BONFIRE_CLASSIC_LOCAL_EVERY:-1}"
    export BONFIRE_CLASSIC_HIDDEN_LOCAL_EVERY="${BONFIRE_CLASSIC_HIDDEN_LOCAL_EVERY:-0}"
    export BONFIRE_CLASSIC_HIDDEN_LOCAL_BURST_ROWS="${BONFIRE_CLASSIC_HIDDEN_LOCAL_BURST_ROWS:-0}"
    export BONFIRE_CLASSIC_FETCHER_EVERY="${BONFIRE_CLASSIC_FETCHER_EVERY:-0}"
    export BONFIRE_CLASSIC_MIN_VISIBLE_LOCAL_ROWS="${BONFIRE_CLASSIC_MIN_VISIBLE_LOCAL_ROWS:-$BONFIRE_CLASSIC_FEED_ROWS}"
    export BONFIRE_CLASSIC_MIN_HIDDEN_LOCAL_ROWS="${BONFIRE_CLASSIC_MIN_HIDDEN_LOCAL_ROWS:-0}"
    export BONFIRE_CLASSIC_REQUIRE_TARGET_INDEX="${BONFIRE_CLASSIC_REQUIRE_TARGET_INDEX:-0}"
    exec "$0" classic-benchmark-stress
    ;;
  classic-benchmark-guest-visible-acl-stress)
    export BONFIRE_CLASSIC_STRESS_DATABASE_URL="${BONFIRE_CLASSIC_GUEST_ACL_DATABASE_URL:-ecto://${POSTGRES_USER}:${POSTGRES_PASSWORD}@${POSTGRES_HOST}:${POSTGRES_PORT}/bonfire_test_classic_guest_acl_stress}"
    export BONFIRE_CLASSIC_VISIBLE_ACL="${BONFIRE_CLASSIC_VISIBLE_ACL:-guests_may_see_read}"
    export BONFIRE_CLASSIC_FEED_ROWS="${BONFIRE_CLASSIC_FEED_ROWS:-1000000}"
    export BONFIRE_CLASSIC_EXACT_FEED_PUBLISH_ROWS="${BONFIRE_CLASSIC_EXACT_FEED_PUBLISH_ROWS:-$BONFIRE_CLASSIC_FEED_ROWS}"
    export BONFIRE_CLASSIC_LOCAL_EVERY="${BONFIRE_CLASSIC_LOCAL_EVERY:-37}"
    export BONFIRE_CLASSIC_HIDDEN_LOCAL_EVERY="${BONFIRE_CLASSIC_HIDDEN_LOCAL_EVERY:-5}"
    export BONFIRE_CLASSIC_HIDDEN_LOCAL_BURST_ROWS="${BONFIRE_CLASSIC_HIDDEN_LOCAL_BURST_ROWS:-100000}"
    export BONFIRE_CLASSIC_FETCHER_EVERY="${BONFIRE_CLASSIC_FETCHER_EVERY:-97}"
    export BONFIRE_CLASSIC_MIN_VISIBLE_LOCAL_ROWS="${BONFIRE_CLASSIC_MIN_VISIBLE_LOCAL_ROWS:-20000}"
    export BONFIRE_CLASSIC_MIN_HIDDEN_LOCAL_ROWS="${BONFIRE_CLASSIC_MIN_HIDDEN_LOCAL_ROWS:-250000}"
    export BONFIRE_CLASSIC_REQUIRED_PAGES="${BONFIRE_CLASSIC_REQUIRED_PAGES:-120}"
    export BONFIRE_CLASSIC_EXPLAIN_PAGE="${BONFIRE_CLASSIC_EXPLAIN_PAGE:-1}"
    export BONFIRE_CLASSIC_BENCH_WORK_MEM="${BONFIRE_CLASSIC_BENCH_WORK_MEM:-1MB}"
    export BONFIRE_CLASSIC_BENCH_EFFECTIVE_CACHE_SIZE="${BONFIRE_CLASSIC_BENCH_EFFECTIVE_CACHE_SIZE:-64MB}"
    export BONFIRE_CLASSIC_BENCH_RANDOM_PAGE_COST="${BONFIRE_CLASSIC_BENCH_RANDOM_PAGE_COST:-4}"
    exec "$0" classic-benchmark-stress
    ;;
  all-with-benchmark)
    "$0" all
    "$0" ui-full-preload-render-stress
    "$0" ui-browser-js
    "$0" classic-benchmark-stress
    ;;
  all-with-strict-benchmark)
    "$0" all
    "$0" ui-full-preload-render-stress
    "$0" ui-browser-js
    "$0" classic-benchmark-stress
    "$0" classic-benchmark-local-heavy
    "$0" classic-benchmark-guest-visible-acl-stress
    ;;
  all)
    "$0" format
    "$0" backend
    "$0" ui
    "$0" ui-presets
    "$0" ui-context
    "$0" ui-auto-short-feed
    "$0" ui-actual-cases
    "$0" ui-time-limit
    "$0" ui-benchmark-target
    ;;
  *)
    echo "Usage: $0 [format|backend|ui|ui-presets|ui-context|ui-auto-short-feed|ui-actual-cases|ui-time-limit|ui-benchmark-target|ui-full-preload-render-stress|ui-browser-js|classic-benchmark|classic-benchmark-stress|classic-benchmark-local-heavy|classic-benchmark-guest-visible-acl-stress|all|all-with-benchmark|all-with-strict-benchmark]" >&2
    exit 64
    ;;
esac
