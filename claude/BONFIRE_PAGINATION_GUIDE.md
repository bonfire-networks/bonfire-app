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