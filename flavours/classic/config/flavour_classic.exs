import Config

config :bonfire_social, Bonfire.Social.Pins, modularity: :enabled

config :bonfire_label, modularity: :disabled

config :bonfire_boundaries, Bonfire.Boundaries.Web.SetBoundariesLive, modularity: :disabled
config :bonfire_boundaries, Bonfire.Boundaries.Web.PreviewBoundariesLive, modularity: :disabled

config :bonfire_ui_reactions, Bonfire.UI.Reactions.BookmarksLive, modularity: :disabled
config :bonfire_ui_reactions, Bonfire.UI.Reactions.BookmarkActionLive, modularity: :disabled

config :bonfire, :ui,
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
