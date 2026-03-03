import Config

#### Flavour-specific compile-time configuration goes here, everything else should be in `Social.RuntimeConfig`

# enable marking comment as answer?
# config :bonfire_social, Bonfire.Social.Answers, modularity: :disabled

# enable content labelling?
# config :bonfire_label, modularity: :disabled
config :bonfire_label, Bonfire.Label.Web.ContentLabelLive, modularity: :disabled

# enable custom boundaries in composer's boundary selector?
# config :bonfire_ui_boundaries, Bonfire.UI.Boundaries.CustomizeBoundaryLive, modularity: :disabled
# enable preview resulting boundaries in composer's boundary selector?
config :bonfire_ui_boundaries, Bonfire.UI.Boundaries.PreviewBoundariesLive, modularity: :disabled

# enable thread locking?
config :bonfire_ui_boundaries, Bonfire.Boundaries.Locking.LiveHandler, modularity: :disabled

# config :bonfire_ui_reactions, Bonfire.UI.Reactions.BookmarksLive, modularity: :disabled
# config :bonfire_ui_reactions, Bonfire.UI.Reactions.BookmarkActionLive, modularity: :disabled

# enable pinning?
config :bonfire_social, Bonfire.Social.Pins, modularity: :disabled
config :bonfire_ui_reactions, Bonfire.UI.Reactions.PinActionLive, modularity: :disabled

# disable emoji reactions
config :bonfire_ui_reactions, Bonfire.UI.Reactions.EmojiReactionsLive, modularity: :disabled

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

# config :bonfire_notify, modularity: :disabled
