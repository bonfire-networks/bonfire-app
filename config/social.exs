import Config

#### Flavour-specific compile-time configuration goes here, everything else should be in `Social.RuntimeConfig`

config :bonfire_social, Bonfire.Social.Pins, modularity: :disabled
# config :bonfire_social, Bonfire.Social.Answers, modularity: :disabled

# config :bonfire_label, modularity: :disabled

config :bonfire_boundaries, Bonfire.UI.Boundaries.SetBoundariesLive, modularity: :disabled
config :bonfire_boundaries, Bonfire.UI.Boundaries.PreviewBoundariesLive, modularity: :disabled

config :bonfire_ui_reactions, Bonfire.UI.Reactions.BookmarksLive, modularity: :disabled
config :bonfire_ui_reactions, Bonfire.UI.Reactions.BookmarkActionLive, modularity: :disabled

config :bonfire, :ui,
  # Register the social custom themes
  themes: [
    "social-dark"
  ],
  themes_light: [
    "social"
  ],
  default_nav_extensions: [
    :bonfire,
    :bonfire_ui_common,
    :bonfire_ui_social,
    :bonfire_ui_reactions,
    :bonfire_ui_messages,
    :bonfire_open_science,
    :bonfire_files
    # :bonfire_ui_search
  ]

config :bonfire_valueflows_api_schema, modularity: :disabled
