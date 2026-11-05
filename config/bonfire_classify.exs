import Config

config :bonfire_classify,
  templates_path: "lib"

# config :bonfire_classify, Bonfire.Classify.Category,
#   has_one: [actor: {Bonfire.Data.ActivityPub.Actor, foreign_key: :id}],
#   has_one: [character: {Bonfire.Data.Identity.Character, foreign_key: :id}],
#   has_one: [profile: {Bonfire.Data.Social.Profile, foreign_key: :id}]
# ^ commented out: `config/bonfire_data.exs` already stitches `:actor`, `:character` and `:profile` onto Category (its `common.([...])` mixins), so these declared them a second time and `bonfire_classify` failed to compile ("field/association :actor already exists on schema")

# the feed filter this extension owns: activities in the outboxes of groups and their topics, either every one this instance knows (`:all`) or the ones the viewer joined (`:joined`), optionally with where the groups are hosted (`:local` or `:remote`), eg. `[:all, :remote]`. A list, as `origin` is; a bare scope is read as a one-item list. Declared here as a field on another extension's struct because `Exto` reads this at compile time and a struct's fields have to exist when it compiles; `Bonfire.Classify.FeedFilters` is what applies it
config :bonfire_social, Bonfire.Social.FeedFilters,
  field: [
    # was `{Ecto.Enum, values: [:all, :joined]}`, which took no origin
    in_groups: Bonfire.Social.FeedFilters.AtomOrStringList
  ]
