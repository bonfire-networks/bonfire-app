# Bonfire Pagination Implementation Guide

This guide outlines the established patterns for implementing pagination in Bonfire components. Use this as a reference for consistent pagination implementations across the codebase.

## Core Architecture

### Components Overview
- **LoadMoreLive**: Reusable pagination component (`bonfire_ui_common/lib/components/paginate/load_more_live.sface`)
- **Live Handlers**: Handle pagination events and data loading
- **Parent LiveViews**: Route events from stateless components to handlers
- **Backend Functions**: Return paginated data with `%{edges: [], page_info: %{}}`

### Data Flow
```
User clicks "Load more" → LoadMoreLive → Parent LiveView → Live Handler → Backend → Updated UI
```

## Implementation Patterns

### 1. Backend Pagination Functions

All pagination functions should use the `many/3` helper and return standardized structure:

```elixir
def list_items(filters, opts \\ []) do
  query
  |> apply_filters(filters)
  |> proload([:associations])
  |> many(true, opts)  # Returns %{edges: [], page_info: %{}}
end
```

**Page Info Structure:**
```elixir
%{
  end_cursor: "cursor_string",
  has_next_page: true/false,
  page_count: 10,
  final_cursor: "final_cursor_string"
}
```

### 2. Live Handler Events

#### Standard load_more Handler Pattern:

```elixir
def handle_event("load_more", %{"context" => context} = params, socket) do
  current_user = current_user(socket)
  
  # Validation
  if validation_fails() do
    {:noreply, assign_flash(socket, :error, l("Error message"))}
  else
    pagination = input_to_atoms(params)
    
    try do
      # Load next page of data
      new_data = YourContext.list_items(
        filters,
        pagination: pagination,
        current_user: current_user
      )
      
      {:noreply,
       socket
       |> assign(
         items: e(assigns(socket), :items, []) ++ e(new_data, :edges, []),
         page_info: e(new_data, :page_info, []),
         previous_page_info: e(assigns(socket), :page_info, nil),
         loading: false
       )}
    rescue
      error ->
        error(error, "Failed to load more #{context}")
        {:noreply, assign_flash(socket, :error, l("Could not load more"))}
    end
  end
end
```

#### Optional preload_more Handler:

```elixir
def handle_event("preload_more", %{"context" => context} = params, socket) do
  # Same as load_more but for infinite scroll preloading
  handle_event("load_more", params, socket)
end
```

### 3. Parent LiveView Event Routing

For stateless components, parent LiveViews must route events:

```elixir
def handle_event("YourModule:load_more", params, socket) do
  maybe_apply(
    YourModule.LiveHandler,
    :handle_event,
    ["load_more", params, socket],
    fallback_return: {:noreply, socket}
  )
end

def handle_event("YourModule:preload_more", params, socket) do
  maybe_apply(
    YourModule.LiveHandler,
    :handle_event,
    ["preload_more", params, socket],
    fallback_return: {:noreply, socket}
  )
end
```

### 4. LoadMoreLive Component Usage

#### Basic Usage:
```surface
<Bonfire.UI.Common.LoadMoreLive
  :if={@page_info}
  live_handler="YourModule"
  page_info={@page_info}
  context={@current_context}
  hide_guest_fallback
  hide_if_no_more
>
  <:if_no_more>
    <p class="text-center text-base-content/70 py-4">{l("That's all!")}</p>
  </:if_no_more>
</Bonfire.UI.Common.LoadMoreLive>
```

#### Key Properties:
- `live_handler`: Module name that handles events
- `page_info`: Pagination metadata from backend
- `context`: Identifies which list/feed for multiple lists on same page
- `hide_if_no_more`: Hide component when no more data
- `infinite_scroll`: Enable/disable infinite scroll behavior

### 5. Required Assigns for Components

Components using pagination should accept:

```elixir
prop items, :list, default: []
prop page_info, :any, default: nil
prop loading, :boolean, default: false
prop context, :string, default: nil
```

### 6. Initial Data Loading Pattern

For initial page loads, use load functions that set up all required state:

```elixir
def load_initial_data(filters, opts, socket) do
  data = YourContext.list_items(filters, opts)
  
  [
    loading: false,
    items: e(data, :edges, []),
    page_info: e(data, :page_info, []),
    previous_page_info: nil,
    context: opts[:context] || "default"
  ]
end
```

## Error Handling Standards

### Validation Patterns:
```elixir
# Check required data exists
if is_nil(required_data) do
  {:noreply, assign_flash(socket, :error, l("Required data missing"))}
```

### Error Recovery:
```elixir
try do
  # pagination logic
rescue
  error ->
    error(error, "Failed to load more #{context}")
    {:noreply, assign_flash(socket, :error, l("Could not load more"))}
end
```

## Testing Patterns

### Test Setup:
```elixir
test "Load more works for component" do
  # Set pagination limit for testing
  original_limit = Config.get(:default_pagination_limit)
  Config.put(:default_pagination_limit, 2)
  
  on_exit(fn ->
    Config.put(:default_pagination_limit, original_limit)
  end)
  
  # Create test data (more than pagination limit)
  # Test initial load shows limited results
  # Test clicking load more shows additional results
end
```

### DOM Assertions:
```elixir
conn = conn(user: user, account: account)
|> visit("/your-page")
|> assert_has("[data-id=item_identifier]", count: 2)
|> click_button("[data-id=load_more]", "Load more")
|> assert_has("[data-id=item_identifier]", count: 4)
```

## State Management Checklist

When implementing pagination, ensure you handle:

- [ ] **Initial Loading**: `loading: false` after data loads
- [ ] **Data Accumulation**: Append new results with `++`
- [ ] **Page Info**: Update with new pagination metadata
- [ ] **Previous Page Info**: Track for navigation/debugging
- [ ] **Error States**: Graceful error handling with user feedback
- [ ] **Empty States**: Handle no data scenarios
- [ ] **Context Tracking**: Support multiple lists per page
- [ ] **Validation**: Check required data before processing

## Component Integration Patterns

### For Stateless Components:
1. Accept `page_info` and `items` as props
2. Include `LoadMoreLive` in template
3. Let parent LiveView handle events

### For Stateful Components:
1. Implement `handle_event("load_more", ...)` 
2. Include `LoadMoreLive` in template
3. Handle events directly

### For Nested Components:
1. Use `phx-target={@myself}` for component-specific events
2. Implement event handlers in component module
3. Use `context` prop to differentiate multiple instances

## Performance Considerations

### Optimizations:
- Use `deferred_join: true` for expensive queries
- Implement proper indexing for pagination queries
- Consider `limit` and `multiply_limit` for dynamic page sizes
- Use `preload_more` for better infinite scroll UX

### Anti-patterns to Avoid:
- Loading all data then paginating in memory
- Not handling error states
- Forgetting to append data (overwriting instead)
- Missing context for multiple lists
- Not validating user permissions for pagination

### Deferred Join Regression Checks

Run these focused checks from the Bonfire app umbrella when changing feed deferred-join pagination or load-more behavior:

When submitting this change across separate repositories, keep the dependency order explicit: `bonfire_common` must include the lightweight test repo guards used by this harness, `bonfire_data_social` must provide `Bonfire.Data.Social.FeedPublish.Migration.add_feed_publish_feed_id_id_index/1` and `Bonfire.Data.Social.Activity.Migration.add_activity_feed_lookup_index/1` before the `bonfire_social` migrations that call them are deployed, and the app umbrella harness assumes sibling checkouts for `bonfire_common`, `bonfire_data_social`, `bonfire_social`, and `bonfire_ui_social`.

```bash
./test-pagination-regression.sh backend
```

```bash
./test-pagination-regression.sh ui
```

```bash
./test-pagination-regression.sh ui-presets
```

```bash
./test-pagination-regression.sh ui-context
```

```bash
./test-pagination-regression.sh ui-auto-short-feed
```

```bash
./test-pagination-regression.sh ui-actual-cases
```

```bash
./test-pagination-regression.sh ui-time-limit
```

```bash
./test-pagination-regression.sh ui-benchmark-target
```

```bash
./test-pagination-regression.sh ui-full-preload-render-stress
```

```bash
./test-pagination-regression.sh classic-benchmark
```

Use `./test-pagination-regression.sh all` to run formatting plus the backend, focused UI, real feed preset load-more, group context leakage, short-feed auto-pagination, deferred-join actual-case, show-older time-limit persistence, and feed benchmark target checks serially. The `ui-time-limit` check targets the tagged show-older date-sorted, non-date sorted, cached-feed, and guest fallback cases. Use `./test-pagination-regression.sh ui-full-preload-render-stress` for the heavier UI path that seeds two 20-item visible local pages separated by a hidden local window, runs the no-time-limit full-preload backend path, renders that same full-preloaded feed component, then renders `/feed/local` and `load_more` through PhoenixTest. That stress also fails if the deferred-join code falls back to the non-deferred query path while recovering the page; it scopes a longer DB ownership timeout to this target because strict fixture setup can outlive the ordinary sandbox default. Use `./test-pagination-regression.sh ui-browser-js` for the real Chromium guest fallback check; it starts the test endpoint with `PHX_SERVER=yes`, uses a non-sandbox test DB checkout, opens both cache-bypassed and cache-enabled `/feed/?time_limit=1` guest flows, clicks the disconnected `load_all_time` anchor and `next_page` link, and fails on browser `pageerror` or `console.error`. Use `./test-pagination-regression.sh all-with-strict-benchmark` as the local pre-release gate when you also need the full preload/render stress, real browser JS check, the 1,000,000-row sparse/hidden Classic-like benchmark, the 1,000,000-row all-local benchmark, and the guest-visible custom ACL stress profile. The script sets a focused lightweight local test environment and forces the social flavour with AI disabled. Only the strict Classic benchmark branch relaxes local test DB query/pool/ownership timeouts and disables server-side statement timeout so large fixture setup or adversarial page walks are not confused with the separate 222ms benchmark gates. It accepts normal database overrides such as `POSTGRES_DB=...` or `DATABASE_URL=...`; when `DATABASE_URL` is provided, its database/user/password/host/port seed the corresponding `POSTGRES_*` defaults, and conflicting `POSTGRES_DB` values are rejected before migrations run. It creates and strictly migrates the configured test database, rejects any non-success extension migration result, refuses database names that do not look like test databases unless `BONFIRE_ALLOW_NON_TEST_DATABASE=1` is set for an intentional throwaway database, and uses a checkout-local lock with a bounded wait to avoid concurrent runs sharing this checkout's `_build/test` state or default test database. This harness is focused regression coverage, not a substitute for a full non-lightweight application run on maintainer hardware; browser paint and logged-in websocket flows still need review if a later change touches those surfaces.

Full preload/render stress knobs:

```bash
BONFIRE_FULL_RENDER_PAGE_LIMIT=20 \
BONFIRE_FULL_RENDER_HIDDEN_MULTIPLIER=32 \
BONFIRE_FULL_RENDER_HIDDEN_EXTRA_ROWS=5 \
BONFIRE_FULL_PRELOAD_MAX_MS=1000 \
BONFIRE_FULL_COMPONENT_RENDER_MAX_MS=3000 \
BONFIRE_FULL_INITIAL_RENDER_MAX_MS=5000 \
BONFIRE_FULL_LOAD_MORE_RENDER_MAX_MS=3000 \
./test-pagination-regression.sh ui-full-preload-render-stress
```

The full preload/render timing gates are integration-regression guards, not the 222ms query target. The 222ms target belongs to the Classic-like query benchmark, while the PhoenixTest timings include full preloads, LiveView rendering, event handling, and test harness overhead.

### Feed Backend Benchmark

Use `Bonfire.UI.Social.Benchmark.feed_backend/0` to compare local feed query timings. The review target is the `query 20 with no time limit` case: guest local feed, page size 20, no time filter, normal boundary checks, and the default feed query path. Diagnostic cases such as `without deferred join` and `ignoring boundaries` are useful for comparison, but they should not be treated as the user-facing target.

### Classic-like Feed Benchmark

Use `./test-pagination-regression.sh classic-benchmark` when the maintainer's Classic database or hardware is not available. The benchmark seeds a test database with synthetic local-feed activity, remote/noise feed rows, fetcher-subject rows, and public ACL rows, then runs the real `FeedActivities.feed(:local, limit: 20, preload: false)` query path with normal boundary checks. This is a query microbenchmark, not a full UI/rendering benchmark. It prints counts, edge counts, first-run and warm-cache timings, relevant feed-publish indexes, whether the `(feed_id, id)` index appears in the plan, and `EXPLAIN (ANALYZE, BUFFERS)` output.

Useful knobs:

```bash
BONFIRE_CLASSIC_FEED_ROWS=200000 \
BONFIRE_CLASSIC_BENCH_ITERATIONS=3 \
BONFIRE_CLASSIC_BENCH_WORK_MEM=4MB \
BONFIRE_CLASSIC_BENCH_EFFECTIVE_CACHE_SIZE=128MB \
BONFIRE_CLASSIC_BENCH_RANDOM_PAGE_COST=4 \
./test-pagination-regression.sh classic-benchmark
```

Set `BONFIRE_CLASSIC_LOCAL_EVERY=493` to make only every 493rd synthetic activity become a public local-feed item. Set `BONFIRE_CLASSIC_HIDDEN_LOCAL_EVERY=23` to add many local-feed rows that fail ACL visibility checks. Set `BONFIRE_CLASSIC_HIDDEN_LOCAL_BURST_ROWS=5000` to make the newest local-feed slice hidden rather than evenly distributed. That sparse, hidden, and bursty mode is useful for checking whether the query still avoids scanning through many recent non-local rows, hidden local rows, and fetcher-subject rows while still returning visible local results.

Use `./test-pagination-regression.sh classic-benchmark-stress` when validating against a stricter Classic-like case before submission. It runs against a throwaway test database, defaulting to `bonfire_test_classic_stress`, and drops that database before and after the run instead of doing large in-place cleanup. The stress command also installs an `EXIT` cleanup trap and wraps the benchmark with `BONFIRE_CLASSIC_STRESS_TIMEOUT_SECONDS`, defaulting to 1800 seconds, so hung seed/query/EXPLAIN runs fail instead of waiting forever. It defaults to 1,000,000 synthetic feed rows, only every 493rd row as a public local-feed item, hidden local-feed rows every 23rd item, a 5,000-row hidden local burst at the newest end of the synthetic range, a fetcher-noise cadence that does not align with the local-feed cadence, 250,000 inserted-then-deleted newer local-feed rows to exercise hot target-index churn, `VACUUM (ANALYZE)` after churn and after the main seed to represent a maintained database with usable visibility-map coverage, one cold-path diagnostic feed run, low `work_mem`, low `effective_cache_size`, and `random_page_cost=4`. The stress target uses `BONFIRE_CLASSIC_FAST_SEED=1` by default so the expensive synthetic setup can bypass trigger overhead, then verifies exact seed row count and table integrity before timing the real query path. It requires 90 full 20-edge cursor pages with no overlap, at least 2,000 visible local rows, at least 40,000 hidden local rows, use of `bonfire_data_social_feed_publish_feed_id_id_idx` on the deep-page plan, no feed-publish sequential scan, no whole-plan temp-block spill, bounded feed-publish plan row volume, tightly bounded heap fetches and rows removed by filter, first measured query time under 222ms after the diagnostic warmup, warm p95 under 222ms, every walked page under 222ms, and walked-page p95 under 222ms.

Use `./test-pagination-regression.sh classic-benchmark-local-heavy` to validate the separate 1,000,000-local-candidate profile. That profile makes every synthetic row a visible local-feed candidate, keeps the same 20-edge and 90-page timing gates, and disables the target-index requirement because `feed_id` is intentionally non-selective in an all-local dataset; the sparse stress profile remains the target-index proof. Use `./test-pagination-regression.sh classic-benchmark-guest-visible-acl-stress` to validate anonymous local-feed rows protected by the `guests_may_see_read` ACL path under a stricter sparse profile: 1,000,000 feed rows, 100,000 hidden newest local rows, 250,000 churn rows, 120 cursor pages, low `work_mem`, low `effective_cache_size`, and `random_page_cost=4`. Use `./test-pagination-regression.sh all-with-strict-benchmark` to run the full preload/render stress and all three strict benchmark profiles after the formatting, backend, and UI checks. Set `BONFIRE_CLASSIC_VACUUM_AFTER_CHURN=0` or `BONFIRE_CLASSIC_VACUUM_AFTER_SEED=0` only when intentionally measuring unmaintained-table risk; that case can fail the cold-path or first-run wall-clock gate even when the query shape is correct. Override other limits with the matching `BONFIRE_CLASSIC_*` environment variables only when documenting why local hardware needs a different gate.

## Debug Helpers

### Common Issues:
1. **Events not triggering**: Check parent LiveView routing
2. **Data not appending**: Verify `++` operator usage
3. **Page info missing**: Ensure backend returns proper structure
4. **Context confusion**: Use unique context values per list

### Debug Functions:
```elixir
# In handlers, use debug to trace data flow
pagination |> debug("pagination_params")
new_data |> debug("loaded_data")
e(assigns(socket), :items, []) |> debug("existing_items")
```

This guide should be used as the canonical reference for all pagination implementations in Bonfire. Follow these patterns to ensure consistency, reliability, and maintainability across the codebase.
