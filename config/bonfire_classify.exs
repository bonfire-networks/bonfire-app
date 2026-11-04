import Config

config :bonfire_classify,
  templates_path: "lib"

# the feed filter this extension owns: activities in the outboxes of groups and their topics, either every one this instance knows (`:all`) or the ones the viewer joined (`:joined`). Declared here as a field on another extension's struct because `Exto` reads this at compile time and a struct's fields have to exist when it compiles; `Bonfire.Classify.FeedFilters` is what applies it
config :bonfire_social, Bonfire.Social.FeedFilters,
  field: [
    in_groups: {Ecto.Enum, values: [:all, :joined]}
  ]
