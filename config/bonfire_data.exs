import Config

#### Pointers configuration

# This tells `Pointers.Tables` which apps to search for tables to
# index. If you add another dependency with Pointables, you will want
# to add it to the search path

config :pointers,
  search_path: [
    :bonfire_data_access_control,
    :bonfire_data_identity,
    :bonfire_data_social,
    :cpub_activities,
    :cpub_blocks,
    :cpub_bookmarks,
    :cpub_comments,
    :cpub_communities,
    :cpub_threads,
    :bonfire,
  ]

#### Flexto Stitching

## WARNING: This is the flaky magic bit. We use configuration to
## compile extra stuff into modules.  If you add new fields or
## relations to ecto models in a dependency, you must recompile that
## dependency for it to show up! You will probably find you need to
## `rm -Rf _build/*/lib/cpub_*` a lot.

## Note: This does not apply to configuration for
## `Pointers.Changesets`, which is read at runtime, not compile time

alias Bonfire.Data.AccessControl.{Access, Acl, Controlled, Grant}
alias Bonfire.Data.ActivityPub.Actor
alias Bonfire.Data.Identity.{Account, Accounted, Credential, Email, User}
alias Bonfire.Data.Social.{
  Block, Bookmark, Character, Circle, Encircle, Follow, FollowCount,
  Like, LikeCount, Profile,
}
alias CommonsPub.{
  Comments.Comment,
  Communities.Communities,
  Features.Feature,
  Threads.Thread,
}

# bonfire_data_access_control

config :bonfire_data_access_control, Access, []
config :bonfire_data_access_control, Acl, []
config :bonfire_data_access_control, Controlled, []
config :bonfire_data_access_control, Grant, []

# bonfire_data_activity_pub

config :bonfire_data_activity_pub, Actor,
  belongs_to: [user: {User, foreign_key: :id, define_field: false}]

# bonfire_data_identity

config :bonfire_data_identity, Account,
  has_one: [email:      {Email,      foreign_key: :id}],
  has_one: [credential: {Credential, foreign_key: :id}],
  has_many: [accounted: Accounted]

config :bonfire_data_identity, Accounted, []
  # belongs_to: [user: {User, foreign_key: :id, define_field: false}]

config :bonfire_data_identity, Credential,
  belongs_to: [account: {Account, foreign_key: :id, define_field: false}],
  rename_attrs: [email_address: :identity],
  password: [length: [min: 8, max: 64]]

config :bonfire_data_identity, Email,
  belongs_to: [account: {Account, foreign_key: :id, define_field: false}]

config :bonfire_data_identity, User,
  has_one: [accounted: {Accounted, foreign_key: :id}],
  has_one: [character: {Character, foreign_key: :id}],
  has_one: [profile:   {Profile,   foreign_key: :id}],
  has_one: [actor:     {Actor,     foreign_key: :id}]

# bonfire_data_social

config :bonfire_data_social, Block, []
config :bonfire_data_social, Bookmark, []

config :bonfire_data_social, Character,
  belongs_to: [user: {User, foreign_key: :id, define_field: false}]

config :bonfire_data_social, Circle, []
config :bonfire_data_social, Encircle, []
config :bonfire_data_social, Follow, []
config :bonfire_data_social, FollowCount, []
config :bonfire_data_social, Like, []
config :bonfire_data_social, LikeCount, []

config :bonfire_data_social, Profile,
  belongs_to: [user: {User, foreign_key: :id, define_field: false}]

