# Bonfire Settings System Documentation

This guide explains how to create, read, and update settings in Bonfire, covering the complete workflow from database storage to UI presentation.

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Settings Hierarchy](#settings-hierarchy)
3. [Core Settings API](#core-settings-api)
4. [Creating Settings Components](#creating-settings-components)
5. [Settings UI Integration](#settings-ui-integration)
6. [Practical Examples](#practical-examples)
7. [Best Practices](#best-practices)
8. [Troubleshooting](#troubleshooting)

## Architecture Overview

Bonfire's settings system is built around a hierarchical scope system that allows for flexible configuration at multiple levels. The system follows these core principles:

### Key Components

- **`Bonfire.Common.Settings`** - Core settings API for get/put/set operations
- **`Bonfire.Data.Identity.Settings`** - Database schema for storing settings as JSON
- **Settings Components** - UI components for settings forms and inputs
- **LiveHandler** - Handles form submissions and real-time updates
- **Scope System** - Manages user/account/instance level settings

### Data Flow

```
User Input → Form → LiveHandler → Settings.set() → Database → Cache → UI Update
```

## Settings Hierarchy

Settings follow a bottom-up hierarchy where more specific settings override general ones:

1. **User Settings** (highest priority) - Individual user preferences
2. **Account Settings** - Shared account/team preferences  
3. **Instance Settings** - System-wide defaults set by admins
4. **OTP Config** - Compile-time and runtime application configuration
5. **Default Values** (lowest priority) - Hardcoded fallbacks

### Scope Examples

```elixir
# User-level setting
Settings.get([:ui, :theme], "light", current_user: user)

# Account-level setting  
Settings.get([:ui, :theme], "light", current_account: account)

# Instance-level setting
Settings.get([:ui, :theme], "light", scope: :instance)
```

## Core Settings API

### Reading Settings

```elixir
# Basic usage
Settings.get(:my_key, "default_value")

# With nested keys
Settings.get([:ui, :theme, :dark_mode], false)

# With user context
Settings.get([:ui, :theme], "light", current_user: user)

# With specific scope
Settings.get([:ui, :theme], "light", scope: :instance)

# Required setting (raises if not found)
Settings.get!([:required, :setting])
```

### Writing Settings

```elixir
# Set single value
Settings.put(:my_key, "new_value", current_user: user)

# Set nested value
Settings.put([:ui, :theme, :dark_mode], true, current_user: user)

# Set multiple values at once
Settings.set(%{
  ui: %{
    theme: "dark",
    font_size: 16
  }
}, current_user: user)

# Instance-level setting (requires admin)
Settings.put(:system_setting, "value", scope: :instance, current_user: admin)
```

### Scope Control

The `scope` parameter determines where settings are stored:

- `:user` - Current user's personal settings
- `:account` - Account/team shared settings  
- `:instance` - System-wide settings (admin only)
- `%User{}` - Specific user object
- `%Account{}` - Specific account object

## Creating Settings Components

There are two main approaches to creating settings components:

### Approach 1: Custom Settings Components

For complex settings that need custom UI logic:

```elixir
defmodule MyExtension.Settings.CustomSettingLive do
  use Bonfire.UI.Common.Web, :stateless_component

  prop scope, :any, default: nil

  declare_settings_component(l("My Custom Setting"),
    icon: "fluent:settings-16-filled",
    description: l("Description of what this setting does"),
    scope: :user  # or :account, :instance
  )
end
```

### Approach 2: Template Components

For simple settings using built-in UI templates:

#### Toggle Setting

```elixir
defmodule MyExtension.Settings.EnableFeatureLive do
  use Bonfire.UI.Common.Web, :stateless_component

  prop scope, :any, default: nil

  declare_settings(:toggle, l("Enable Feature"),
    keys: [MyExtension, :enable_feature],
    description: l("Enable this awesome feature"),
    default_value: false,
    scope: :user
  )
end
```

#### Select Setting

```elixir
defmodule MyExtension.Settings.ThemeSelectLive do
  use Bonfire.UI.Common.Web, :stateless_component

  prop scope, :any, default: nil

  declare_settings(:select, l("Choose Theme"),
    keys: [MyExtension, :theme],
    options: [
      light: l("Light Theme"),
      dark: l("Dark Theme"),
      auto: l("Auto (System)")
    ],
    default_value: :auto,
    description: l("Select your preferred theme"),
    scope: :user
  )
end
```

#### Input Setting

```elixir
defmodule MyExtension.Settings.ApiKeyLive do
  use Bonfire.UI.Common.Web, :stateless_component

  prop scope, :any, default: nil

  declare_settings(:input, l("API Key"),
    keys: [MyExtension, :api_key],
    description: l("Enter your API key for external service"),
    scope: :user
  )
end
```

#### Number Setting

```elixir
defmodule MyExtension.Settings.ItemLimitLive do
  use Bonfire.UI.Common.Web, :stateless_component

  prop scope, :any, default: nil

  declare_settings(:number, l("Items per page"),
    keys: [MyExtension, :items_per_page],
    default_value: 20,
    unit: l("items"),
    description: l("How many items to show per page"),
    scope: :user
  )
end
```

### Available Template Types

- `:toggle` - Simple on/off checkbox
- `:toggles` - Multiple checkboxes
- `:radios` - Radio button group
- `:select` - Dropdown selection
- `:input` - Text input field
- `:textarea` - Multi-line text area
- `:number` - Number input with unit label

## Settings UI Integration

### In Preferences Pages

Settings are automatically discovered and included in preferences pages. The file structure determines organization:

```
extensions/my_extension/lib/components/settings/
├── my_setting_live.ex          # Appears in main preferences
└── preferences/
    └── advanced_live.ex        # Appears in advanced section
```

### Manual Form Integration

For custom forms, use the standardized form pattern:

```html
<form data-scope="my_setting_scope" name="settings" phx-change="Bonfire.Common.Settings:set">
  <input name="scope" value={@scope} type="hidden">
  
  <Bonfire.UI.Common.SettingsToggleLive
    name={l("Enable Feature")}
    description={l("This enables the awesome feature")}
    keys={[MyExtension, :enable_feature]}
    scope={@scope}
  />
</form>
```

### LiveHandler Integration

The `Bonfire.Common.Settings.LiveHandler` provides these events:

- `"set"` - Set multiple settings from form data
- `"put"` - Set single setting by key path
- `"save"` - Save settings with success message

```elixir
def handle_event("set", attrs, socket) do
  # Automatically handled by LiveHandler
  # Shows flash message on success
end
```

## Practical Examples

### Example 1: Simple Toggle Setting

Create a setting to enable/disable a feature:

1. **Create the settings component:**

```elixir
# extensions/my_extension/lib/components/settings/enable_notifications_live.ex
defmodule MyExtension.Settings.EnableNotificationsLive do
  use Bonfire.UI.Common.Web, :stateless_component

  prop scope, :any, default: nil

  declare_settings(:toggle, l("Enable Email Notifications"),
    keys: [MyExtension, :enable_notifications],
    description: l("Receive email notifications for new messages"),
    default_value: true,
    scope: :user
  )
end
```

2. **Use the setting in your code:**

```elixir
# Check if notifications are enabled
if Settings.get([MyExtension, :enable_notifications], true, current_user: user) do
  # Send notification
  send_email_notification(user, message)
end
```

### Example 2: Select Setting with Multiple Options

Create a setting for choosing notification frequency:

```elixir
# extensions/my_extension/lib/components/settings/notification_frequency_live.ex
defmodule MyExtension.Settings.NotificationFrequencyLive do
  use Bonfire.UI.Common.Web, :stateless_component

  prop scope, :any, default: nil

  declare_settings(:select, l("Notification Frequency"),
    keys: [MyExtension, :notification_frequency],
    options: [
      immediate: l("Immediate"),
      hourly: l("Hourly Digest"),
      daily: l("Daily Digest"),
      never: l("Never")
    ],
    default_value: :daily,
    description: l("How often to receive notification emails"),
    scope: :user
  )
end
```

### Example 3: Custom Settings Component

For complex settings that need custom logic:

```elixir
# extensions/my_extension/lib/components/settings/advanced_config_live.ex
defmodule MyExtension.Settings.AdvancedConfigLive do
  use Bonfire.UI.Common.Web, :stateless_component

  prop scope, :any, default: nil

  declare_settings_component(l("Advanced Configuration"),
    icon: "fluent:settings-16-filled",
    description: l("Advanced settings for power users"),
    scope: :user
  )

  def render(assigns) do
    ~F"""
    <div class="space-y-4">
      <form data-scope="advanced_config" name="settings" phx-change="Bonfire.Common.Settings:set">
        <input name="scope" value={@scope} type="hidden">
        
        <div class="form-control">
          <label class="label">
            <span class="label-text">{l("Custom API Endpoint")}</span>
          </label>
          <input 
            type="url" 
            name={input_name([MyExtension, :api_endpoint])}
            value={Settings.get([MyExtension, :api_endpoint], "", context: @__context__)}
            class="input input-bordered"
            placeholder="https://api.example.com"
          />
        </div>

        <div class="form-control">
          <label class="label">
            <span class="label-text">{l("Timeout (seconds)")}</span>
          </label>
          <input 
            type="number" 
            name={input_name([MyExtension, :timeout])}
            value={Settings.get([MyExtension, :timeout], 30, context: @__context__)}
            class="input input-bordered"
            min="1"
            max="300"
          />
        </div>
      </form>
    </div>
    """
  end

  defp input_name(keys) do
    Bonfire.Common.Settings.LiveHandler.input_name(keys)
  end
end
```

### Example 4: Instance-Level Setting

Create an admin-only instance setting:

```elixir
# extensions/my_extension/lib/components/settings/instance_limits_live.ex
defmodule MyExtension.Settings.InstanceLimitsLive do
  use Bonfire.UI.Common.Web, :stateless_component

  prop scope, :any, default: nil

  declare_settings(:number, l("Maximum Items Per User"),
    keys: [MyExtension, :max_items_per_user],
    default_value: 1000,
    unit: l("items"),
    description: l("Maximum number of items each user can create"),
    scope: :instance  # Admin only
  )
end
```

## Best Practices

### Naming Conventions

1. **Keys should be hierarchical:**
   ```elixir
   [MyExtension, :feature, :sub_feature]  # Good
   [:my_random_key]                       # Avoid
   ```

2. **Use your extension as the top-level key:**
   ```elixir
   [Bonfire.UI.Social, :feed, :default_sort]  # Good
   [:feed, :default_sort]                      # Avoid - conflicts possible
   ```

### Default Values

Always provide sensible defaults:

```elixir
# Good - provides fallback
Settings.get([MyExt, :timeout], 30, current_user: user)

# Bad - could return nil unexpectedly  
Settings.get([MyExt, :timeout], current_user: user)
```

### Scoping

Choose appropriate scopes:

- **User scope** - Personal preferences (theme, language, notifications)
- **Account scope** - Team/organization settings (branding, policies)
- **Instance scope** - System-wide configuration (limits, features)

### Performance

- Settings are cached in OTP config for instance-level settings
- User and account settings are loaded from database
- Avoid frequent setting changes in hot code paths
- Preload settings associations when passing user/account objects

### Security

- Instance settings require admin permissions
- Never store secrets in settings (use environment variables)
- Validate and sanitize user input
- Consider privacy implications of settings data

### Testing

```elixir
defmodule MyExtension.SettingsTest do
  use Bonfire.DataCase
  alias Bonfire.Common.Settings

  test "setting default value" do
    user = fake_user!()
    
    # Test default
    assert Settings.get([MyExt, :feature], false, current_user: user) == false
    
    # Test setting value
    {:ok, _} = Settings.put([MyExt, :feature], true, current_user: user)
    assert Settings.get([MyExt, :feature], false, current_user: user) == true
  end

  test "hierarchy works correctly" do
    user = fake_user!()
    
    # Instance setting
    {:ok, _} = Settings.put([MyExt, :limit], 100, scope: :instance, skip_boundary_check: true)
    
    # User override
    {:ok, _} = Settings.put([MyExt, :limit], 50, current_user: user)
    
    # User setting takes precedence
    assert Settings.get([MyExt, :limit], 10, current_user: user) == 50
  end
end
```

## Troubleshooting

### Common Issues

1. **Settings not saving:**
   - Check that form has `phx-change="Bonfire.Common.Settings:set"`
   - Ensure `scope` input is included in form
   - Verify user has permission for the scope

2. **Settings not loading:**
   - Confirm keys match exactly (atoms vs strings)
   - Check that default value is provided
   - Verify context includes current_user/current_account

3. **Permission errors:**
   - Instance settings require admin permissions
   - Check `skip_boundary_check: true` for testing
   - Verify user is properly authenticated

4. **Settings not appearing in UI:**
   - Check file is in correct extension directory
   - Verify component uses `declare_settings_component` or `declare_settings`
   - Ensure extension is enabled

### Debugging

Enable debug logging:

```elixir
# In your settings call
Settings.get([MyExt, :setting], default, 
  current_user: user,
  debug: true  # Shows lookup process
)
```

Check database directly:

```sql
SELECT * FROM bonfire_data_identity_settings 
WHERE id = 'user_id_here';
```

### Key Validation

Settings keys should follow these patterns:

```elixir
# Good patterns
[MyExtension, :feature_name]
[MyExtension, :category, :setting]
[Bonfire.UI.Common, :theme, :dark_mode]

# Bad patterns - avoid
[:global_setting]              # Too generic
["string_key"]                 # Use atoms
[MyExtension, "mixed", :types] # Be consistent
```

## Conclusion

The Bonfire settings system provides a flexible, hierarchical way to manage configuration at multiple levels. By following the patterns and best practices outlined in this guide, you can create robust, user-friendly settings for your extensions.

Key takeaways:

- Use the hierarchical scope system (user > account > instance)
- Choose between custom components and template components based on complexity
- Always provide default values and consider performance
- Test your settings thoroughly and follow security best practices
- Leverage the automatic UI integration for consistent user experience

For more examples, examine existing settings components in the `bonfire_ui_*` extensions.