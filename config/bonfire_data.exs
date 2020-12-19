import Config

#### Sentinel Data Services

# Search these apps for Pointable schemas to index

config :pointers,
  search_path: [
    :bonfire_data_access_control,
    :bonfire_data_activity_pub,
    :bonfire_data_identity,
    :bonfire_data_social,
    :cpub_activities,
    :cpub_comments,
    :cpub_communities,
    :cpub_threads,
    :bonfire,
  ]

# Search these apps for Verbs to index

config :bonfire_data_access_control,
  search_path: [
    :bonfire_common,
    :bonfire_me,
    :bonfire,
  ]


#### Flexto Stitching

## WARNING: This is the flaky magic bit. We use configuration to
## compile extra stuff into modules.  If you add new fields or
## relations to ecto models in a dependency, you must recompile that
## dependency for it to show up! You will probably find you need to
## `rm -Rf _build/*/lib/bonfire_data_*` a lot.

## Note: This does not apply to configuration for
## `Pointers.Changesets`, which is read at runtime, not compile time

# first up, pointers could have all the mixins we're using. TODO

alias Pointers.{Pointer, Table}

config :pointers, Pointer, []
config :pointers, Table, []

# now let's weave everything else together for convenience

alias Bonfire.Data.AccessControl.{
  Access, Acl, Controlled, InstanceAdmin, Grant, Interact, Verb
}
alias Bonfire.Data.ActivityPub.{Actor, Peer, Peered}
alias Bonfire.Data.Identity.{
  Account, Accounted, Caretaker, Character, Credential, Email, Self, User
}
alias Bonfire.Data.Social.{
  Activity, Article, Block, Bookmark, Circle, Created, Encircle, Feed, FeedPublish,
  Follow, FollowCount, Like, LikeCount, Mention, Named, Post, PostContent, Profile,
}
alias CommonsPub.{
  Comments.Comment,
  Communities.Communities,
  Features.Feature,
  Threads.Thread,
}

# bonfire_data_access_control

config :bonfire_data_access_control, Access,
  has_one: [named: {Named, foreign_key: :id}]

config :bonfire_data_access_control, Acl,
  has_one: [named: {Named, foreign_key: :id}]

config :bonfire_data_access_control, Controlled, []
config :bonfire_data_access_control, Grant, []
config :bonfire_data_access_control, Interact, []
config :bonfire_data_access_control, Verb, []

# bonfire_data_activity_pub

config :bonfire_data_activity_pub, Actor,
  belongs_to: [user: {User, foreign_key: :id, define_field: false}]

config :bonfire_data_activity_pub, Peer, []
config :bonfire_data_activity_pub, Peered, []

# bonfire_data_identity

config :bonfire_data_identity, Account,
  has_one: [credential:     {Credential,    foreign_key: :id}],
  has_one: [email:          {Email,         foreign_key: :id}],
  has_one: [instance_admin: {InstanceAdmin, foreign_key: :id}]

config :bonfire_data_identity, Accounted,
  belongs_to: [user: {User, foreign_key: :id, define_field: false}]

config :bonfire_data_identity, Caretaker, []

config :bonfire_data_identity, Character, []

config :bonfire_data_identity, Credential,
  belongs_to: [account: {Account, foreign_key: :id, define_field: false}]

config :bonfire_data_identity, Email,
  must_confirm: true,
  belongs_to: [account: {Account, foreign_key: :id, define_field: false}]

config :bonfire_data_identity, Self, []

config :bonfire_data_identity, User,
  has_one: [actor:        {Actor,       foreign_key: :id}],
  has_one: [accounted:    {Accounted,   foreign_key: :id}],
  has_one: [character:    {Character,   foreign_key: :id}],
  has_one: [follow_count: {FollowCount, foreign_key: :id}],
  has_one: [like_count:   {LikeCount,   foreign_key: :id}],
  has_one: [profile:      {Profile,     foreign_key: :id}],
  has_one: [self:         {Self,        foreign_key: :id}],
  has_many: [encircles: {Encircle, foreign_key: :subject_id}]

# bonfire_data_social

config :bonfire_data_social, Activity, []
config :bonfire_data_social, Block, []
config :bonfire_data_social, Bookmark, []

config :bonfire_data_social, Character,
  belongs_to: [user: {User, foreign_key: :id, define_field: false}]

config :bonfire_data_social, Circle,
  has_one: [caretaker: {Caretaker, foreign_key: :id}],
  has_one: [named:     {Named, foreign_key: :id}]

config :bonfire_data_social, Encircle, []
config :bonfire_data_social, Feed, []
config :bonfire_data_social, FeedPublish, []
config :bonfire_data_social, Follow, []
config :bonfire_data_social, FollowCount, []
config :bonfire_data_social, Like, []
config :bonfire_data_social, LikeCount, []
config :bonfire_data_social, Mention, []
config :bonfire_data_social, Named, []

config :bonfire_data_social, Post,
  has_one: [post_content: {PostContent, foreign_key: :id}],
  has_one: [created: {Created, foreign_key: :id}]

config :bonfire_data_social, PostContent, []

config :bonfire_data_social, Created, []

config :bonfire_data_social, Profile,
  belongs_to: [user: {User, foreign_key: :id, define_field: false}]
