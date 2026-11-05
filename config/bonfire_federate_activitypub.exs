import Config

alias Bonfire.Federate.ActivityPub.Adapter

actor_types = ["Person", "Group", "Application", "Service", "Organization"]

config :bonfire,
  # enable/disable logging of federation logic
  log_federation: true,
  federation_fallback_module: Bonfire.Social.APActivities

config :bonfire, actor_AP_types: actor_types

# Incoming activity types Bonfire does not model and skips cleanly (e.g. PeerTube `View`
# view-count pings) instead of erroring/retrying. See bonfire-app#1802.
config :bonfire_federate_activitypub, :skip_activity_types, ["View", "Listen", "WatchAction"]

# Each incoming `interactionPolicy` key, and the verbs it grants or denies (see `AdapterUtils.ap_incoming_interaction_policy_to_verb_grants/2`)
config :bonfire_federate_activitypub, :interaction_policy_verbs, %{
  "canLike" => [:like],
  "canAnnounce" => [:boost],
  "canReply" => [:reply],
  "canQuote" => [:quote]
}

# Deleting one of these takes an activity back, so it federates as its module's `Undo` (`ap_publish_activity(_, :delete, _)`) rather than a `Delete`. Only list types whose module has that clause: any other falls into its catch-all and publishes a create
config :bonfire_federate_activitypub, :undo_on_delete_types, [
  Bonfire.Data.Social.Boost,
  Bonfire.Data.Social.Like,
  Bonfire.Data.Social.Follow,
  Bonfire.Label
]

# config :bonfire, Bonfire.Instance,
# hostname: hostname,
# description: desc
