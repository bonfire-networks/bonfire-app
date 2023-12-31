import Config

config :bonfire_api_graphql,
  modularity: :disabled

config :bonfire_social, Bonfire.Social.Pins, modularity: :disabled

config :bonfire, :ui,
  default_nav_extensions: [
    :bonfire_ui_common,
    :bonfire_ui_social,
    :bonfire_ui_reactions,
    :bonfire_ui_messages
    # :bonfire_ui_search
  ]
