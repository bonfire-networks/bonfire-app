# Handle events in your Live Views with LiveHandlers

`Bonfire.UI.Common.LiveHandlers` is a core module that simplifies event delegation for Phoenix LiveView applications within the Bonfire ecosystem. It provides a standardized way to handle various LiveView events (params, events, info) and route them to appropriate handler modules, enabling you to easily handle the same event in multiple live views or components using the same code.

## Overview

The LiveHandlers system allows you to:

1. Define event handling logic in dedicated modules 
2. Route events from multiple views or components based on naming conventions
3. Handle complex event delegation scenarios
4. Standardize error handling across your application


## Usage

### Creating a LiveHandler module

To create a LiveHandler for your Bonfire extension:

```elixir
defmodule Bonfire.MyExtension.LiveHandler do
  use Bonfire.UI.Common.Web, :live_handler

  # Implement handler callbacks
  def handle_event("my_action", params, socket) do
    # Your handling logic
    {:noreply, socket}
  end
  
  def handle_info({:my_message, data}, socket) do
    # Process the message
    {:noreply, socket}
  end
  
  def handle_params(%{"my_param" => value}, uri, socket) do
    # Handle URL parameters
    {:noreply, socket}
  end

end
```

### Triggering LiveHandlers

#### From Templates

You can trigger the `handle_event` in your LiveHandler from any view or component:

```html
<button phx-click="Bonfire.MyExtension:perform_action">Click me</button>

<form phx-submit="Bonfire.MyExtension:save_form">
  <!-- form content -->
</form>
```

#### From URIs

You can trigger `handle_params` in your LiveHandler based on on URIs:

```heex
<a href="?Bonfire.MyExtension[after]=<%= e(@page_info, :end_cursor, nil) %>">Load more</a>
```

#### From PubSub

You can trigger `handle_info` in your LiveHandler from any live view or component:

```elixir
PubSub.broadcast(topic, {{Bonfire.MyExtension, :new_item}, item})
```

## Examples

### Handle Form Submission

In your view or component:
```html
<form phx-submit="Bonfire.MyExtension:save_form">
  <!-- form content -->
</form>
```

In your LiveHandler module:
```elixir
def handle_event("save_form", %{"post" => post_attrs}, socket) do
  case Posts.create(current_user(socket), post_attrs) do
    {:ok, post} ->
      {:noreply, socket |> assign_flash(:info, "Post created successfully!")}
    {:error, changeset} ->
      {:noreply, socket |> assign(:changeset, changeset) |> assign_error("Failed to create post")}
  end
end
```

### Handle URL Parameters

In your view or component:
```heex
<a href="?Bonfire.MyExtension[after]=<%= e(@page_info, :end_cursor, nil) %>">
  Load more
</a>
```

```elixir
def handle_params(%{"after" => cursor}, _uri, socket) do
  items = fetch_items_after_cursor(cursor)
  {:noreply, socket |> assign(:items, items)}
end
```

## Key Concepts

### Event Routing

LiveHandlers uses naming conventions to route events:

- `phx-click="Bonfire.Posts:delete"` and `phx-submit="Bonfire.Posts.LiveHandler:delete"` both route to `Bonfire.Posts.LiveHandler.handle_event("delete", ...)`
- `PubSub.broadcast(topic, {{Bonfire.Social.Feeds, :new_activity}, activity})` and `PubSub.broadcast(topic, {"Bonfire.Social.Feeds.LiveHandler:new_activity", item})` both route to `Bonfire.Social.Feeds.LiveHandler.handle_info({:new_activity, activity}, ...)`
- `?Bonfire.Social.Feeds[after]=<cursor>` and `/?Bonfire.Social.Feeds[after]=<cursor>`  and `/any_view?Bonfire.Social.Feeds.LiveHandler[after]=<cursor>` all route to `Bonfire.Social.Feeds.LiveHandler.handle_params(%{"after" => cursor}, ...)`

### Error Handling

All LiveHandler callbacks are wrapped in error protection using `ErrorHandling.undead/2` to prevent crashes.

## API Documentation

For more detailed documentation, see the `Bonfire.UI.Common.LiveHandlers` module documentation.

