import Config

config :bonfire_tag,
  templates_path: "lib"

config :bonfire_social_graph, skip_boundary_check_types: [Bonfire.Tag.Hashtag]