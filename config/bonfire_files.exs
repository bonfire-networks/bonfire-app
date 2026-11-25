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

# a link with an embeddable player is an audio embed (`audio/embed`) when its host is one of these or under one, or has a name without a dot in it (eg. a Funkwhale instance), else a video embed: oEmbed has no reliable audio type, and podcasts often call themselves `video.*` in Open Graph
config :bonfire_files, Bonfire.Files,
  audio_embed_hosts: [
    "spotify.com",
    "music.apple.com",
    "podcasts.apple.com",
    "soundcloud.com",
    "bandcamp.com",
    "mixcloud.com",
    "acast.com",
    "buzzsprout.com",
    "spreaker.com",
    "iheart.com",
    "podbean.com",
    "audiomack.com",
    "deezer.com",
    "tidal.com",
    "anchor.fm",
    "funkwhale",
    "castopod"
  ],
  # a link on one of these hosts (or under one) is a document embed (`document/embed`), listed by the documents feed, unless it is a paper (`research`)
  document_embed_hosts: [
    "scribd.com",
    "slideshare.net",
    "issuu.com",
    "speakerdeck.com",
    "docs.google.com",
    "yumpu.com",
    "calameo.com"
  ]

# the library's `%URI{}` uploads are fetched through `Bonfire.Common.HTTP` (private and loopback hosts refused on every hop, body size capped) instead of its default `:httpc` fetch
config :entrepot, :uri_fetcher, {Bonfire.Files, :fetch_body}
