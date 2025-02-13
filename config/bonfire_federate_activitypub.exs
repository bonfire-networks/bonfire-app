import Config

alias Bonfire.Federate.ActivityPub.Adapter

actor_types = ["Person", "Group", "Application", "Service", "Organization"]

config :bonfire,
  # enable/disable logging of federation logic
  log_federation: true,
  federation_fallback_module: Bonfire.Social.APActivities

config :bonfire, actor_AP_types: actor_types

# config :bonfire, Bonfire.Instance,
# hostname: hostname,
# description: desc
