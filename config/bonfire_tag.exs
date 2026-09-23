import Config

config :bonfire_tag,
  templates_path: "lib"

config :bonfire_social_graph, skip_boundary_check_types: [Bonfire.Tag.Hashtag]

# the feed filter this extension owns: what a thing is tagged with, by id (which is what a mention is) or by hashtag name. Declared here as a field on another extension's struct because `Exto` reads this at compile time and a struct's fields have to exist when it compiles; `Bonfire.Tag.FeedFilters` is what applies it
config :bonfire_social, Bonfire.Social.FeedFilters,
  field: [
    tags: Bonfire.Social.FeedFilters.StringList,
    exclude_tags: Bonfire.Social.FeedFilters.StringList
  ]
