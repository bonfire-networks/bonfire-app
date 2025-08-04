# Bonfire PubSub System Guide

This guide explains how the Publish-Subscribe (PubSub) pattern is implemented and used throughout the Bonfire framework.

## Overview

Bonfire's PubSub system provides a way for different parts of the application to communicate asynchronously without direct coupling. It's built on top of Phoenix PubSub and enables real-time features like notifications, live feed updates, and presence tracking.

The PubSub pattern is fundamental to Bonfire's architecture:

1. **Publishers** broadcast messages to specific topics
2. **Subscribers** receive messages from topics they've subscribed to
3. No direct dependency exists between publishers and subscribers

## Core Components

### `Bonfire.Common.PubSub`

The main module that provides the PubSub functionality is located at `extensions/bonfire_common/lib/pubsub/pubsub.ex`. It offers a simplified and enhanced API on top of Phoenix's PubSub system.

Key functions:

- `subscribe/2`: Subscribe to one or multiple topics
- `broadcast/2`: Broadcast messages to one or multiple topics
- `broadcast_with_telemetry/3`: Broadcast with OpenTelemetry tracing information

### Topics in Bonfire

Topics in Bonfire are typically string identifiers that represent:

1. **User feeds**: Updates to a user's feed
2. **Threads**: New replies to a conversation
3. **Presence channels**: User online/offline status
4. **Notification channels**: User-specific notifications

## Common Usage Patterns

### 1. Broadcasting Activities to Feeds

In `Bonfire.Social.LivePush`, PubSub is used to push new activities to user feeds:

```elixir
# Broadcasting a new activity to multiple feed IDs
PubSub.broadcast(feed_ids, {
  {Bonfire.Social.Feeds, :new_activity},
  [
    feed_ids: feed_ids,
    activity: activity
  ]
})
```

### 2. Broadcasting to Thread Participants

When someone replies to a thread, all participants are notified:

```elixir
# Notifying thread participants of a new reply
PubSub.broadcast(
  thread_id,
  {{Bonfire.Social.Threads.LiveHandler, :new_reply}, {thread_id, activity}}
)
```

### 3. User Presence Tracking

`Bonfire.UI.Common.Presence` uses Phoenix Presence built on top of PubSub to track online users:

```elixir
# Tracking a user's presence
track(
  self(),
  "bonfire:presence",
  user_id,
  %{
    pid: self(),
    joined_at: :os.system_time(:seconds)
  }
)
```

### 4. Sending Notifications

`Bonfire.UI.Common.Notifications` broadcasts notifications to specific users:

```elixir
# Broadcasting a notification to specific users
PubSub.broadcast(user_ids, {
  Bonfire.UI.Common.Notifications,
  %{
    title: title,
    message: message,
    url: url,
    icon: icon
  }
})
```

## LiveView Integration

Bonfire heavily uses Phoenix LiveView, which integrates natively with PubSub for real-time UI updates.

### Subscribing in LiveView Components

```elixir
def mount(_params, _session, socket) do
  if connected?(socket) do
    # Subscribe to relevant topics
    Bonfire.Common.PubSub.subscribe("feed:#{current_user_id(socket)}", socket)
  end
  
  {:ok, socket}
end
```

### Handling PubSub Messages in LiveView

```elixir
# Handling a new activity in a feed
def handle_info(
  {{Bonfire.Social.Feeds, :new_activity}, %{activity: activity}},
  socket
) do
  {:noreply, update(socket, :activities, &[activity | &1])}
end
```

## Advanced Features

### Telemetry Integration

PubSub includes OpenTelemetry integration for performance monitoring:

```elixir
# Broadcasting with telemetry
Bonfire.Common.PubSub.broadcast_with_telemetry(
  topic,
  message,
  "#{inspect(MyModule)}.my_function/1"
)
```

### Conditional Subscription

The framework prevents unnecessary subscriptions when LiveViews aren't connected:

```elixir
# Only subscribes if the socket is connected or a user is present
def subscribe(topic, socket) when is_binary(topic) do
  if socket_connected_or_user?(socket) do
    do_subscribe(topic)
  else
    debug(topic, "LiveView is not connected so we skip subscribing to")
  end
end
```

## Best Practices

1. **Be specific with topics**: Use descriptive, hierarchical topic names
2. **Keep payloads small**: Avoid sending large data structures in PubSub messages
3. **Handle disconnections**: Ensure your code can handle situations where PubSub fails
4. **Use pattern matching**: Handle different message types clearly with pattern matching
5. **Namespace topics**: Prefix topics with module names to prevent collisions

## Common Patterns in Bonfire

1. **Feed Updates**: New posts or activities appearing in user feeds
2. **Thread Updates**: New replies in conversations
3. **Notifications**: User-facing alerts about mentions, likes, etc.
4. **Counter Updates**: Incrementing unread notification counters
5. **Presence Tracking**: Monitoring online users

## Example Implementation Flow

1. A user creates a post
2. The post is saved in the database
3. `Bonfire.Social.LivePush.push_activity/3` is called
4. PubSub broadcasts the new activity to relevant feed topics
5. LiveView components subscribed to those topics receive the message
6. Components update their state and re-render

## Conclusion

Bonfire's PubSub system is central to its real-time capabilities. Understanding how it works will help you effectively build new features, debug existing ones, and appreciate the architecture of the framework.

When extending or modifying Bonfire, consider how PubSub can enable real-time functionality without tightly coupling your components.