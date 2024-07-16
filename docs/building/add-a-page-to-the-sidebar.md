# Bonfire Navigation Sidebar

## Overview

The Bonfire framework includes the navigation on the left sidebar, which can include pages from various extensions. Different navigation menus can be defined based on the current page (e.g., Explore and Settings pages have distinct menus).

## Key Concepts

1. Create new navigation menus
2. Add pages to existing menus
3. Override default navigation
4. Use custom navigation components

## Creating a New Navigation Menu

To create a new menu for your extension:

1. Use the `declare_extension` macro in one of your extension views (typically the extension homepage).
2. Configure your extension with options like name, icon, description, and navigation menu.

```elixir
declare_extension("Your Extension Name",
  icon: "🎆",
  description: "A short description to display in the extension settings",
  default_nav: [
    ExtensionName.Path.YourPageLive,
    ExtensionName.Path.AnotherPageLive,
    # Add more pages as needed
  ]
)
```

3. For each page in `default_nav`, use the `declare_nav_link` macro to define link properties:

```elixir
declare_nav_link(l("Your Page"),
  page: "your_page",
  href: "/your_page",
  icon: "ph:search",
  icon_active: "ph:search-fill"
)
```

## Using the Default Navigation Menu

To use the default navigation menu instead of your extension's menu:

1. In each view's `mount` function, set the `nav_items` property:

```elixir
def mount(params, session, socket) do
  {:ok,
   socket
   |> assign(
      nav_items: Bonfire.Common.ExtensionModule.default_nav()
    )
  }
end
```

## Overriding Default Navigation with a Custom Menu

To override the default navigation for specific pages:

1. Create a custom navigation menu component.
2. Use the `declare_nav_component("sidebar description")` macro on the custom menu.
3. In each view's `mount` function, set the `nav_items` property:

```elixir
def mount(params, session, socket) do
  {:ok,
   socket
   |> assign(
      nav_items: [ExtensionName.Path.YourPageLive.declared_nav()]
    )
  }
end
```
