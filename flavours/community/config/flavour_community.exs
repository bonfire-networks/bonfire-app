import Config

config :bonfire_ui_topics,
  modularity: :disabled

# Please note that most of these are defaults meant to be overridden by instance admins in Settings rather than edited here
config :bonfire, :ui,
  # end theme
  hide_app_switcher: true,
  feed_object_extension_preloads_disabled: false,
  smart_input_activities: [
    category: "Create a topic",
    label: "New label"
  ]
