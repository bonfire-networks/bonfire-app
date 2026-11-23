import Config

#### Extension-specific compile-time configuration goes here, everything else should be in `Community.RuntimeConfig`

# Please note that most of these are defaults meant to be overridden by instance admins in Settings rather than edited here
config :bonfire, :ui,
  # end theme
  hide_app_switcher: true,
  feed_object_extension_preloads_disabled: false,
  smart_input_activities: [
    category: "Create a topic",
    label: "New label"
  ]

config :bonfire_social, Bonfire.Social.Pins, modularity: true
# config :bonfire_ui_reactions, Bonfire.UI.Reactions.PinActionLive, modularity: true

# enable marking comment as answer?
config :bonfire_social, Bonfire.Social.Answers, modularity: :disabled

# The dashboard's main-area widgets, in default order: ids of widgets in `Bonfire.UI.Common.Widgets.registry/0`. Instances set their own defaults and people their own choice in dashboard settings.
config :bonfire, Bonfire.Web.Views.DashboardLive,
  widgets: [
    main: [:welcome, :instance_pinned, :trending_discussions, :polls_closing_soon, :suggested_profiles]
  ]
