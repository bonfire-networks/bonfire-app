import Config

# see `Bonfire.Files.RuntimeConfig` for what env vars to set

# the feed filters this extension owns: the media an activity carries, by type. Declared here as fields on another extension's struct because `Exto` reads this at compile time and a struct's fields have to exist when it compiles; `Bonfire.Files.FeedFilters` is what applies them
config :bonfire_social, Bonfire.Social.FeedFilters,
  field: [
    media_types: Bonfire.Social.FeedFilters.AtomOrStringList,
    exclude_media_types: Bonfire.Social.FeedFilters.AtomOrStringList,
    # only media with a file of ours (an upload, or an imported file with its storage), not a link preview or an embed
    media_has_file: :boolean
  ]

# the library's `%URI{}` uploads are fetched through `Bonfire.Common.HTTP` (private and loopback hosts refused on every hop, body size capped) instead of its default `:httpc` fetch
config :entrepot, :uri_fetcher, {Bonfire.Files, :fetch_body}
