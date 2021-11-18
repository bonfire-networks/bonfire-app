import Config

alias Bonfire.Federate.ActivityPub.Adapter

actor_types = ["Person", "Group", "Application", "Service", "Organization"]

config :bonfire,
  federation_search_path: [
    :bonfire_common,
    :bonfire_me,
    :bonfire_social,
    :bonfire_valueflows,
    :bonfire_classify,
    :bonfire_geolocate,
    :bonfire_quantify
    ],
  log_federation: true, # enable/disable logging of federation logic
  federation_fallback_module: Bonfire.Social.APActivities

config :bonfire, Adapter,
  actor_types: actor_types

# config :bonfire, Bonfire.Instance,
  # hostname: hostname,
  # description: desc
