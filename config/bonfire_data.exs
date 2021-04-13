import Config

#### Base configuration

# Choose password hashing backend
# Note that this corresponds with our dependencies in mix.exs
hasher = if config_env() in [:dev, :test], do: Pbkdf2, else: Argon2

config :bonfire_data_identity, Bonfire.Data.Identity.Credential,
  hasher_module: hasher

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
    :bonfire_quantify,
    :bonfire_geolocate,
    :bonfire_valueflows,
    :bonfire_tag,
    :bonfire_classify,
    :bonfire_data_shared_users,
  ]

# Search these apps for Verbs to index

config :bonfire_data_access_control,
  search_path: [
    :bonfire_me,
    :bonfire_boundaries,
    :bonfire_social,
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
  Account, Accounted, Caretaker, Character, Credential, Email, Self, User, Named
}
alias Bonfire.Data.Social.{
  Activity, Article, Block, Bookmark, Circle, Created, Encircle, Feed, FeedPublish, Inbox, Message, Follow, FollowCount, Boost, BoostCount, Like, LikeCount, Flag, FlagCount, Mention, Post, PostContent, Profile, Replied
}

# bonfire_data_access_control

config :bonfire_data_access_control, Access,
  has_one: [named: {Named, foreign_key: :id}],
  has_one: [caretaker: {Caretaker, foreign_key: :id}]

config :bonfire_data_access_control, Acl,
  has_one: [named: {Named, foreign_key: :id}],
  has_one: [caretaker: {Caretaker, foreign_key: :id}]

config :bonfire_data_access_control, Controlled, []
config :bonfire_data_access_control, Grant,
  belongs_to: [subject_character: {Character, foreign_key: :subject_id, define_field: false}],
  belongs_to: [subject_profile: {Profile, foreign_key: :subject_id, define_field: false}],
  belongs_to: [subject_circle: {Circle, foreign_key: :subject_id, define_field: false}],
  belongs_to: [subject_named: {Named, foreign_key: :subject_id, define_field: false}]

config :bonfire_data_access_control, Interact, []
config :bonfire_data_access_control, Verb, []

# bonfire_data_activity_pub

config :bonfire_data_activity_pub, Actor,
  belongs_to: [user: {User, foreign_key: :id, define_field: false}]

config :bonfire_data_activity_pub, Peer, []
config :bonfire_data_activity_pub, Peered, []

# bonfire_data_identity

config :bonfire_data_identity, Account,
  has_one:      [credential:     {Credential,    foreign_key: :id}],
  has_one:      [email:          {Email,         foreign_key: :id}],
  has_one:      [inbox:          {Inbox,         foreign_key: :id}],
  many_to_many: [users:          {User, join_through: "bonfire_data_identity_accounted", join_keys: [account_id: :id, id: :id]}],
  many_to_many: [shared_users:   {User, join_through: "bonfire_data_shared_user_accounts", join_keys: [account_id: :id, shared_user_id: :id]}]

config :bonfire_data_identity, Accounted,
  belongs_to: [user: {User, foreign_key: :id, define_field: false}]

config :bonfire_data_identity, Caretaker, []

config :bonfire_data_identity, Character,
  has_one:    [actor:           {Actor,         foreign_key: :id}],
  has_one:    [profile:         {Profile,       foreign_key: :id}],
  has_one:    [user:            {User,          foreign_key: :id}],
  has_one:    [feed:            {Feed,          foreign_key: :id}],
  has_one:    [inbox:           {Inbox,         foreign_key: :id}],
  has_many:   [feed_publishes:  {FeedPublish,   references: :id, foreign_key: :feed_id}],
  has_many:   [followers:       {Follow,        foreign_key: :following_id, references: :id}],
  has_many:   [followings:      {Follow,        foreign_key: :follower_id, references: :id}],
  has_one:    [follow_count:    {FollowCount,   foreign_key: :id}]

config :bonfire_data_identity, Credential,
  belongs_to: [account: {Account, foreign_key: :id, define_field: false}]

config :bonfire_data_identity, Email,
  must_confirm: true,
  belongs_to: [account: {Account, foreign_key: :id, define_field: false}]

config :bonfire_data_identity, Self, []

config :bonfire_data_identity, User,
  has_one:  [accounted:      {Accounted,     foreign_key: :id}],
  has_one:  [profile:        {Profile,       foreign_key: :id}],
  has_one:  [character:      {Character,     foreign_key: :id}],
  has_one:  [actor:          {Actor,         foreign_key: :id}],
  has_one:  [instance_admin: {InstanceAdmin, foreign_key: :id}],
  has_many: [likes:          {Like,          foreign_key: :liker_id, references: :id}],
  has_one:  [self:           {Self,          foreign_key: :id}],
  has_one:  [peered:         {Peered,        foreign_key: :id}],
  has_many: [encircles:      {Encircle,      foreign_key: :subject_id}],
  has_one:  [shared_user:    {Bonfire.Data.SharedUser,     foreign_key: :id}],
  many_to_many: [caretaker_accounts:   {Account, join_through: "bonfire_data_shared_user_accounts", join_keys: [shared_user_id: :id, account_id: :id]}]
  # has_one:  [geolocation:      {Bonfire.Geolocate.Geolocation}]


# bonfire_data_social

config :bonfire_data_social, Activity,
  belongs_to: [subject_user: {User, foreign_key: :subject_id, define_field: false}],
  belongs_to: [subject_character: {Character, foreign_key: :subject_id, define_field: false}],
  belongs_to: [subject_profile: {Profile, foreign_key: :subject_id, define_field: false}],
  belongs_to: [object_post: {Post, foreign_key: :object_id, define_field: false}],
  belongs_to: [object_post_content: {PostContent, foreign_key: :object_id, define_field: false}],
  belongs_to: [object_message: {Message, foreign_key: :object_id, define_field: false}],
  has_one:    [boost_count:   {BoostCount, foreign_key: :id, references: :object_id}],
  has_one:    [like_count:   {LikeCount, foreign_key: :id, references: :object_id}],
  has_many:   [boosts: {Boost, foreign_key: :boosted_id, references: :object_id}],
  has_many:   [likes: {Like, foreign_key: :liked_id, references: :object_id}],
  has_one:    [my_like: {Like, foreign_key: :liked_id, references: :object_id}],
  has_one:    [my_boost: {Boost, foreign_key: :boosted_id, references: :object_id}],
  has_one:    [my_flag: {Flag, foreign_key: :flagged_id, references: :object_id}],
  has_one:    [replied: {Replied, foreign_key: :id, references: :object_id}],
  # has_one:    [reply_to: {[through: [:replied, :reply_to]]}],
  # has_one:    [reply_to_post: {[through: [:replied, :reply_to_post]]}],
  # has_one:    [reply_to_post_content: {[through: [:replied, :reply_to_post_content]]}],
  # has_one:    [reply_to_creator_character: {[through: [:replied, :reply_to_creator_character]]}],
  # has_one:    [reply_to_creator_profile: {[through: [:replied, :reply_to_creator_profile]]}],
  # has_one:    [thread_post: {[through: [:replied, :thread_post]]}],
  # has_one:    [thread_post_content: {[through: [:replied, :thread_post_content]]}],
  has_one:    [object_created: {Created, foreign_key: :id, references: :object_id}],
  # has_one:    [object_creator_user: {[through: [:object_created, :creator_user]]}],
  # has_one:    [object_creator_character: {[through: [:object_created, :creator_character]]}],
  # has_one:    [object_creator_profile: {[through: [:object_created, :creator_profile]]}],
  has_one:    [controlled:     {Controlled, foreign_key: :id, references: :object_id}]

config :bonfire_data_social, Circle,
  has_one: [caretaker: {Caretaker, foreign_key: :id}],
  has_one: [named:     {Named, foreign_key: :id}]
  # has_many: [encircles:      {Encircle,      foreign_key: :circle_id}]

config :bonfire_data_social, Encircle,
  belongs_to: [subject_user: {User, foreign_key: :subject_id, define_field: false}],
  belongs_to: [subject_character: {Character, foreign_key: :subject_id, define_field: false}],
  belongs_to: [subject_profile: {Profile, foreign_key: :subject_id, define_field: false}]

config :bonfire_data_social, Feed,
  belongs_to: [character: {Character, foreign_key: :id, define_field: false}],
  belongs_to: [user: {User, foreign_key: :id, define_field: false}]

config :bonfire_data_social, FeedPublish, []
config :bonfire_data_social, Follow,
  belongs_to: [follower_character: {Character, foreign_key: :follower_id, define_field: false}],
  belongs_to: [follower_profile: {Profile, foreign_key: :follower_id, define_field: false}],
  belongs_to: [followed_character: {Character, foreign_key: :followed_id, define_field: false}],
  belongs_to: [followed_profile: {Profile, foreign_key: :followed_id, define_field: false}]

config :bonfire_data_social, FollowCount, []
config :bonfire_data_social, Block, []
config :bonfire_data_social, Like, []
config :bonfire_data_social, LikeCount, []
config :bonfire_data_social, Bookmark, []

config :bonfire_data_social, Message,
  has_one:  [post_content: {PostContent, foreign_key: :id}],
  has_one:  [created: {Created, foreign_key: :id}],
  has_many: [activities: {Activity, foreign_key: :object_id, references: :id}],
  has_one:  [activity: {Activity, foreign_key: :object_id, references: :id}], # needs on clause
  has_one:  [like_count:   {LikeCount,   foreign_key: :id}],
  has_many: [likes: {Like, foreign_key: :liked_id, references: :id}],
  has_one:  [my_like: {Like, foreign_key: :liked_id, references: :id}],
  has_one:  [my_flag: {Flag, foreign_key: :flagged_id, references: :id}],
  has_one:  [replied: {Replied, foreign_key: :id}],
  has_many: [direct_replies: {Replied, foreign_key: :reply_to_id}],
  has_one:  [controlled:     {Controlled, foreign_key: :id}]

config :bonfire_data_social, Mention, []
config :bonfire_data_social, Named, []

config :bonfire_data_social, Post,
  has_one:  [post_content: {PostContent, foreign_key: :id}],
  has_one:  [created: {Created, foreign_key: :id}],
  # has_one:  [creator_user: {[through: [:created, :creator_user]]}],
  # has_one:  [creator_character: {[through: [:created, :creator_character]]}],
  # has_one:  [creator_profile: {[through: [:created, :creator_profile]]}],
  has_many: [activities: {Activity, foreign_key: :object_id, references: :id}],
  has_one:  [activity: {Activity, foreign_key: :object_id, references: :id}], # needs on clause
  has_one:  [like_count:   {LikeCount,   foreign_key: :id}],
  has_many: [likes: {Like, foreign_key: :liked_id, references: :id}],
  has_one:  [my_like: {Like, foreign_key: :liked_id, references: :id}],
  has_one:  [my_boost: {Boost, foreign_key: :boosted_id, references: :id}],
  has_one:  [my_flag: {Flag, foreign_key: :flagged_id, references: :id}],
  has_one:  [replied: {Replied, foreign_key: :id}],
  # has_one:  [reply_to: {[through: [:replied, :reply_to]]}],
  # has_one:  [reply_to_post: {[through: [:replied, :reply_to_post]]}],
  # has_one:  [reply_to_post_content: {[through: [:replied, :reply_to_post_content]]}],
  # has_one:  [reply_to_creator_character: {[through: [:replied, :reply_to_creator_character]]}],
  # has_one:  [reply_to_creator_profile: {[through: [:replied, :reply_to_creator_profile]]}],
  has_many: [direct_replies: {Replied, foreign_key: :reply_to_id}],
  # has_one:  [thread_post: {[through: [:replied, :thread_post]]}],
  # has_one:  [thread_post_content: {[through: [:replied, :thread_post_content]]}],
  has_one:  [controlled:     {Controlled, foreign_key: :id}]

config :bonfire_data_social, PostContent, []

config :bonfire_data_social, Replied,
  belongs_to: [post: {Post, foreign_key: :id, define_field: false}],
  belongs_to: [post_content: {PostContent, foreign_key: :id, define_field: false}],
  has_many: [activities: {Activity, foreign_key: :object_id, references: :id}],
  has_one:  [activity: {Activity, foreign_key: :object_id, references: :id}],
  has_one: [reply_to_post: {Post, foreign_key: :id, references: :reply_to_id}],
  has_one: [reply_to_post_content: {PostContent, foreign_key: :id, references: :reply_to_id}],
  has_one:  [reply_to_created: {Created, foreign_key: :id, references: :reply_to_id}],
  # has_one:  [reply_to_creator_user: {[through: [:reply_to_created, :creator_user]]}],
  # has_one:  [reply_to_creator_character: {[through: [:reply_to_created, :creator_character]]}],
  # has_one:  [reply_to_creator_profile: {[through: [:reply_to_created, :creator_profile]]}],
  # has_one:  [like_count:   {LikeCount,   foreign_key: :id}],
  has_many: [direct_replies: {Replied, foreign_key: :reply_to_id, references: :id}],
  has_many: [thread_replies: {Replied, foreign_key: :thread_id, references: :id}],
  has_one: [thread_post: {Post, foreign_key: :id, references: :thread_id}],
  has_one: [thread_post_content: {PostContent, foreign_key: :id, references: :thread_id}],
  has_one: [controlled:     {Controlled, foreign_key: :id, references: :id}]

config :bonfire_data_social, Created,
  belongs_to: [creator_user: {User, foreign_key: :creator_id, define_field: false}],
  belongs_to: [creator_character: {Character, foreign_key: :creator_id, define_field: false}],
  belongs_to: [creator_profile: {Profile, foreign_key: :creator_id, define_field: false}]

config :bonfire_data_social, Profile,
  belongs_to: [user: {User, foreign_key: :id, define_field: false}],
  has_one:    [controlled:     {Controlled, foreign_key: :id, references: :id}]

######### other extensions

# optional mixin relations for tags that are characters (eg Category) or any other type of objects
config :bonfire_tag, Bonfire.Tag,
  # for objects that are follow-able and can federate activities
  has_one: [character:    {Bonfire.Data.Identity.Character,    references: :id, foreign_key: :id}],
  # has_one: [actor:        {Bonfire.Data.ActivityPub.Actor,     references: :id, foreign_key: :id}],
  has_one: [follow_count: {Bonfire.Data.Social.FollowCount,    references: :id, foreign_key: :id}],
  # for likeable objects
  has_one: [like_count:   {Bonfire.Data.Social.LikeCount,      references: :id, foreign_key: :id}],
  # name/description
  has_one: [profile:      {Bonfire.Data.Social.Profile,        references: :id, foreign_key: :id}],
  # for taxonomy categories/topics
  has_one: [category:     {Bonfire.Classify.Category,          references: :id, foreign_key: :id}],
  # for locations
  has_one: [geolocation:  {Bonfire.Geolocate.Geolocation,      references: :id, foreign_key: :id}]

# add references of tags to any tagged Pointer
config :pointers, Pointers.Pointer,
  many_to_many: [
    tags: {
      Bonfire.Tag,
      join_through: "bonfire_tagged",
      unique: true,
      join_keys: [pointer_id: :id, tag_id: :id],
      on_replace: :delete
    }
  ]

# add references of tagged objects to any Category
# config :bonfire_classify, Bonfire.Classify.Category,
#   many_to_many: [
#     tags: {
#       Bonfire.Tag,
#       join_through: "bonfire_tagged",
#       unique: true,
#       join_keys: [tag_id: :id, pointer_id: :id],
#       on_replace: :delete
#     }
#   ]

# add references of tagged objects to any Geolocation
# config :bonfire_geolocate, Bonfire.Geolocate.Geolocation,
#   many_to_many: [
#     tags: {
#       Bonfire.Tag,
#       join_through: "bonfire_tagged",
#       unique: true,
#       join_keys: [tag_id: :id, pointer_id: :id],
#       on_replace: :delete
#     }
#   ]


# all data types included in federation
config :bonfire, :all_types, [User, Post]

# Model - Context module mappings
config :bonfire_data_social, :context_modules,
  follow: Bonfire.Social.Follows
