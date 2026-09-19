import Config

#### Extension-specific compile-time configuration goes here, everything else should be in `Bovenjan.RuntimeConfig`

# Please note that most of these are defaults meant to be overridden by instance admins in Settings rather than edited here
config :bonfire, :ui,
  hide_app_switcher: true,
  feed_object_extension_preloads_disabled: false,
  smart_input_activities: [
    category: "Create a topic",
    label: "New label"
  ],
  themes_light: [
    "bovenjan"
  ],
  themes_dark: [
    "bovenjan-dark"
  ]

# config :bonfire_social, Bonfire.Social.Pins, modularity: true
# config :bonfire_ui_reactions, Bonfire.UI.Reactions.PinActionLive, modularity: true

# enable marking comment as answer?
config :bonfire_social, Bonfire.Social.Answers, modularity: :disabled

# Which getting-started steps the sidebar widget offers, and in what order. Each key is declared by the extension whose feature it is about, along with its copy and its completion detector, so this only chooses between them, and a step whose extension is disabled here drops out on its own. Manual completion ("Mark done") is always available, so a step with no detector still works.
# `notifications` comes after the steps that give somebody something to be notified about. Its action is the card that asks this browser for permission rather than a link anywhere, and the step goes once notifications reach them on any device.
config :bonfire_ui_common, Bonfire.UI.Common.WidgetGettingStartedLive,
  actions: [:profile, :read_rules, :notifications, :first_follow, :first_post]
