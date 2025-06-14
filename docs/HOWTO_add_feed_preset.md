# How to Add a New Feed Preset in Bonfire

This guide walks through the process of adding a new feed preset to Bonfire, using the Events feed as an example.

## Overview

Feed presets in Bonfire are pre-configured feed definitions that determine:
- What content is displayed
- Who can access the feed
- How the data is loaded and optimized
- UI presentation and navigation

## Step 1: Locate the Configuration File

Feed presets are defined in:
```
/extensions/bonfire_social/lib/runtime_config.ex
```

## Step 2: Define the Feed Preset

Add your new feed preset to the `feed_presets` list in the runtime configuration. Feed presets are defined as a keyword list where the key is the feed's atom identifier.

### Basic Structure

```elixir
your_feed_name: %{
  name: l("Display Name"),
  built_in: true,
  description: l("Description of what this feed shows"),
  filters: %FeedFilters{
    # Filter configuration
  },
  icon: "icon-name",
  assigns: [
    # UI configuration
  ]
}
```

### Example: Events Feed

```elixir
events: %{
  name: l("Events"),
  built_in: true,
  description: l("Events and gatherings"),
  filters: %FeedFilters{
    feed_name: :events,
    object_types: ["Event"],  # ActivityPub Event type
    exclude_activity_types: [:like, :boost, :flag]
  },
  icon: "ph:calendar-blank-bold",
  assigns: [
    selected_tab: :events,
    page: "events",
    page_title: l("Events"),
    feedback_title: l("No events found"),
    feedback_message: l("There are no upcoming events to show. Events from other federated platforms like Mobilizon will appear here.")
  ]
}
```

## Step 3: Configure Feed Filters

The `FeedFilters` struct accepts various filtering options:

### Common Filter Options

- **`feed_name`**: Internal identifier for the feed (typically matches the preset key)
- **`activity_types`**: Include only these activity types (e.g., `[:create, :like, :boost]`)
- **`exclude_activity_types`**: Exclude these activity types
- **`object_types`**: Filter by object type (e.g., `[:post]`, `["Event"]`)
- **`exclude_object_types`**: Exclude specific object types
- **`subjects`**: Filter by who performed the activity
- **`objects`**: Filter by what was acted upon
- **`creators`**: Filter by content creators
- **`media_types`**: Filter by media type (e.g., `["image", "video"]`)
- **`origin`**: Filter by origin (`:local` or `:remote`)
- **`tags`**: Filter by hashtags
- **`time_limit`**: Limit to content from last N days
- **`sort_by`**: Sort order (e.g., `:num_replies`)
- **`sort_order`**: `:asc` or `:desc`

### Example Configurations

```elixir
# Media-specific feed
images: %{
  filters: %FeedFilters{
    media_types: ["image"]
  }
}

# Local content only
local_posts: %{
  filters: %FeedFilters{
    origin: :local,
    object_types: [:post]
  }
}

# User-specific activities
user_activities: %{
  filters: %FeedFilters{
    exclude_activity_types: [:like, :follow]
  },
  parameterized: %{subjects: [:by]}
}
```

## Step 4: Set Permissions

Configure who can access the feed:

- **`current_user_required: true`**: Requires user to be logged in
- **`instance_permission_required: :permission_name`**: Requires specific permission (e.g., `:mediate`)
- **`exclude_from_nav: true`**: Hide from navigation menus
- **`opts: [include_flags: true]`**: Additional permission options

## Step 5: Configure UI Settings

The `assigns` list contains UI-specific settings:

```elixir
assigns: [
  selected_tab: :your_tab,           # Tab identifier
  page: "your_page",                 # Page route
  page_title: l("Page Title"),       # Page header
  feed_title: l("Feed Title"),       # Feed section title
  feedback_title: l("Empty Title"),  # Empty state title
  feedback_message: l("Empty msg"),  # Empty state message
  hide_filters: true,                # Hide filter UI
  showing_within: :context,          # Display context
  no_header: true                    # Hide header
]
```

## Step 6: Add Preload Rules (Optional but Recommended)

Optimize data loading by adding specific preload rules for your feed. Find the `preload_rules` configuration section and add:

```elixir
"Your Feed Name" => %{
  match: %{feed_name: :your_feed},
  include: [:with_object_more, :tags, :maybe_sensitive_for_me],
  exclude: [:with_parent, :notifications_object_creator]
}
```

### Common Preload Options

**Include options:**
- `:with_subject` - Load activity subject (who performed action)
- `:with_creator` - Load object creator
- `:with_object_more` - Load object with profile/character data
- `:with_media` - Load media attachments
- `:with_reply_to` - Load replied-to content
- `:with_seen` - Add seen/unseen status
- `:tags` - Load tags/categories
- `:emoji` - Load emoji reactions
- `:sensitivity` - Load content warnings
- `:activity_name` - Load activity display names

**Exclude options:**
- `:with_parent` - Skip parent relationships
- `:notifications_object_creator` - Skip creator notifications
- `:with_object_peered` - Skip federation data

## Step 7: Format and Test

1. Run the formatter:
   ```bash
   mix format extensions/bonfire_social/lib/runtime_config.ex
   ```

2. Restart your Bonfire server to load the new configuration

3. Test accessing your feed:
   - Via UI navigation (if not excluded from nav)
   - Via direct URL: `/feed/your_feed_name`
   - Via API/GraphQL queries

## Advanced Features

### Parameterized Feeds

For dynamic feeds that accept parameters:

```elixir
hashtag: %{
  built_in: true,
  description: "Activities with a specific hashtag",
  filters: %FeedFilters{},
  parameterized: %{tags: [:tags]}
}
```

### Custom Query Functions

For complex queries, specify a custom base query:

```elixir
bookmarks: %{
  base_query_fun: &Bonfire.Social.Bookmarks.base_query/0,
  # ... other config
}
```

### Special Feed Types

Some feeds bypass standard patterns:

```elixir
curated: %{
  # Uses custom query via Pins.list_instance_pins
  filters: %FeedFilters{feed_name: :curated}
}
```

## Common Feed Preset Patterns

### 1. Activity-Based Feeds
Query activities through the Activity table:
```elixir
notifications: %{
  filters: %FeedFilters{
    feed_name: :notifications,
    show_objects_only_once: false
  }
}
```

### 2. Edge-Based Feeds
Query relationships directly through the Edge table:
```elixir
my_flags: %{
  filters: %FeedFilters{
    activity_types: [:flag]
  },
  parameterized: %{subjects: [:me]}
}
```

### 3. Media Feeds
Filter by media content:
```elixir
videos: %{
  filters: %FeedFilters{
    media_types: ["video"]
  }
}
```

### 4. User-Specific Feeds
Require authentication and filter by current user:
```elixir
my_events: %{
  current_user_required: true,
  parameterized: %{subjects: [:me]}
}
```

## Troubleshooting

1. **Feed not appearing**: Check permissions and `exclude_from_nav` setting
2. **No data loading**: Verify filter configuration matches existing data
3. **Performance issues**: Add appropriate preload rules
4. **Permission errors**: Verify `current_user_required` and permission settings

## Next Steps

After adding a feed preset:
1. Consider adding UI components if needed
2. Add tests for the new feed
3. Document the feed in user-facing documentation
4. Consider internationalization for all user-visible strings