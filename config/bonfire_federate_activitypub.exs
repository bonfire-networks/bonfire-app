import Config

alias Bonfire.Federate.ActivityPub.Adapter
alias Bonfire.Data.AccessControl.{
  Access, Acl, Controlled, InstanceAdmin, Grant, Interact, Verb
}
alias Bonfire.Data.ActivityPub.{Actor, Peer, Peered}
alias Bonfire.Data.Identity.{
  Account, Accounted, Caretaker, Character, Credential, Email, Self, User
}
alias Bonfire.Data.Social.{
  Activity, Article, Block, Bookmark, Circle, Created, Encircle, Feed, FeedPublish,
  Follow, FollowCount, Like, LikeCount, Mention, Named, Post, PostContent, Profile, Replied
}

alias Bonfire.Me.{Users, Characters}

alias Bonfire.Social.Follows

types_agents = [
  User,
  # Organisation
]

types_characters =
  types_agents ++
    [
      # Community,
      # Collection,
      Bonfire.Geolocate.Geolocation,
      Bonfire.Classify.Category
    ]

types_inventory = [
  Post,
  # Resources.Resource,
  Bonfire.Quantify.Unit,
  Bonfire.Classify.Category,
  ValueFlows.Planning.Intent,
  ValueFlows.Proposal,
  ValueFlows.Observation.EconomicEvent,
  ValueFlows.Observation.EconomicResource,
  ValueFlows.Observation.Process,
  ValueFlows.Knowledge.ProcessSpecification,
  ValueFlows.Knowledge.ResourceSpecification
]

types_actions = [
  Like,
  Block,
  Flag,
  Follow,
]

types_others = [
  # Instance,
  # Uploads.Upload, # FIXME
  Bonfire.Quantify.Measure,
  Bonfire.Tag,
  Activity,
  Feed,
  Peer,
]

types_all_contexts = types_characters ++ types_inventory
types_all = types_all_contexts ++ types_actions ++ types_others

# configure which modules will receive which ActivityPub activities/objects

actor_modules = %{
  "Person" => Users.ActivityPub,
  "Group" => Communities,
  "MN:Collection" => Collections,
  "Organization" => Organisations,
  "Application" => Characters,
  "Service" => Characters,
  fallback: Characters
}

activity_modules = %{
  "Follow" => Follows,
  "Like" => Likes,
  "Flag" => Flags,
  "Block" => Blocks,
  "Delete" => Contexts.Deletion,
  fallback: Activities
}

inventory_modules = %{
  "Note" => Posts,
  "Article" => Posts,
  "Question" => Posts,
  "Answer" => Posts,
  # "Document" => Resources,
  # "Page" => Resources,
  # "Video" => Resources,
  fallback: Posts
}

object_modules =
  Map.merge(inventory_modules, %{
    "Follow" => Follows,
    "Like" => Likes,
    "Flag" => Flags,
    "Block" => Blocks
  })

actor_types = Map.keys(actor_modules)
activity_types = Map.keys(activity_modules) ++ ["Create", "Update", "Accept", "Announce", "Undo"]
inventory_types = Map.keys(inventory_modules)
object_types = Map.keys(object_modules)
all_types = Enum.dedup(actor_types ++ activity_types ++ inventory_types ++ object_types)

config :bonfire, :all_types, all_types

config :bonfire, Adapter,
  actor_modules: actor_modules,
  actor_types: actor_types,
  activity_modules: activity_modules,
  activity_types: activity_types,
  object_modules: object_modules,
  inventory_types: inventory_types,
  object_types: object_types,
  all_types: all_types

config :bonfire, Instance,
  # hostname: hostname,
  # description: desc,
  # what to show or exclude in Instance Timeline
  default_outbox_query_contexts: List.delete(types_all_contexts, Like),
  types_characters: types_characters,
  types_inventory: types_inventory,
  types_actions: types_actions,
  types_all: types_all
