import Config

#### Base configuration

# Choose password hashing backend
# Note that this corresponds with our dependencies in mix.exs
hasher = if config_env() in [:dev, :test], do: Pbkdf2, else: Argon2

config :bonfire_data_identity, Bonfire.Data.Identity.Credential,
  hasher_module: hasher

#### Sentinel Data Services

# Search these apps/extensions for Pointable ecto schema definitions to index
pointable_schema_extensions = [
    :bonfire_data_access_control,
    :bonfire_data_activity_pub,
    :bonfire_data_identity,
    :bonfire_data_social,
    :bonfire,
    :bonfire_quantify,
    :bonfire_geolocate,
    :bonfire_valueflows,
    :bonfire_tag,
    :bonfire_classify,
    :bonfire_data_shared_users,
    :bonfire_files
  ]
config :pointers, :search_path, pointable_schema_extensions

# Search these apps/extensions for context or queries modules to index (i.e. they contain modules with a queries_module/0 or context_modules/0 function)
context_and_queries_extensions = pointable_schema_extensions ++ [
    :bonfire_common,
    :bonfire_me,
    :bonfire_social,
    :bonfire_valueflows
  ]
config :bonfire, :query_modules_search_path,   context_and_queries_extensions
config :bonfire, :context_modules_search_path, context_and_queries_extensions

# Search these apps/extensions for Verbs to index (i.e. they contain modules with a declare_verbs/0 function)
config :bonfire_data_access_control,
  search_path: [
    # :bonfire_me,
    :bonfire_boundaries,
    # :bonfire_social,
    # :bonfire,
  ]

#### Alias modules for readability
alias Pointers.{Pointer, Table}
alias Bonfire.Data.AccessControl.{
  Acl, Controlled, InstanceAdmin, Grant, Interact, Verb, Circle, Encircle
}
alias Bonfire.Data.ActivityPub.{Actor, Peer, Peered}
alias Bonfire.Data.Edges.{Edge,EdgeTotal}
alias Bonfire.Data.Identity.{
  Account, Accounted, Caretaker, Character, Credential, Email, Named, Self, User,
}
alias Bonfire.Data.Social.{
  Activity, Article, Block, Bookmark, Created, Feed, FeedPublish,
  Inbox, Message, Follow, Boost, Like, Flag, Mention, Post,
  PostContent, Profile, Replied,
}
alias Bonfire.Classify.Category
alias Bonfire.Geolocate.Geolocation
alias Bonfire.Files.Media

#### Flexto Stitching

## WARNING: This is the flaky magic bit. We use configuration to
## compile extra stuff into modules.  If you add new fields or
## relations to ecto models in a dependency, you must recompile that
## dependency for it to show up! You will probably find you need to
## `rm -Rf _build/*/lib/bonfire_data_*` a lot.

## Note: This does not apply to configuration for
## `Pointers.Changesets`, which is read at runtime, not compile time

# first up, pointers could have all the mixins we're using. TODO

config :pointers, Pointer,
  [code: quote do
    @like_ulid   "11KES11KET0BE11KEDY0VKN0WS"
    @boost_ulid  "300STANN0VNCERESHARESH0VTS"
    @follow_ulid "70110WTHE1EADER1EADER1EADE"
    # pointables
    has_one :circle, unquote(Circle), foreign_key: :id
    has_one :user, unquote(User), foreign_key: :id
    has_one :post, unquote(Post), foreign_key: :id
    has_one :message, unquote(Message), foreign_key: :id
    # mixins
    has_one :named, unquote(Named), foreign_key: :id
    has_one :caretaker, unquote(Caretaker), foreign_key: :id
    has_one :controlled, unquote(Controlled), foreign_key: :id
    has_one :created, unquote(Created), foreign_key: :id
    has_one :peered, unquote(Peered), foreign_key: :id, references: :id
    has_one :activity, unquote(Activity), foreign_key: :object_id, references: :id
    has_one :post_content, unquote(PostContent), foreign_key: :id
    has_one :replied, unquote(Replied), foreign_key: :id
    has_one :profile, unquote(Profile), foreign_key: :id
    has_one :character, unquote(Character), foreign_key: :id
    has_one :actor, unquote(Actor), foreign_key: :id
    has_one :edge, unquote(Edge), foreign_key: :id
    has_one :like_count, unquote(EdgeTotal), foreign_key: :id, references: :id, where: [table_id: @like_ulid]
    has_one :boost_count, unquote(EdgeTotal), foreign_key: :id, references: :id, where: [table_id: @boost_ulid]
    has_one :follow_count, unquote(EdgeTotal), foreign_key: :id, references: :id, where: [table_id: @follow_ulid]
    has_many :direct_replies, unquote(Replied), foreign_key: :reply_to_id
    # add references of tags to any tagged Pointer
    many_to_many :tags, unquote(Bonfire.Tag),
      join_through: "bonfire_tagged",
      unique: true,
      join_keys: [pointer_id: :id, tag_id: :id],
      on_replace: :delete
  end]

config :pointers, Table, []

# now let's weave everything else together for convenience

# bonfire_data_access_control

config :bonfire_data_access_control, Access,
  [code: quote do
    has_one :named, unquote(Named),foreign_key: :id
    has_one :caretaker, unquote(Caretaker), foreign_key: :id
  end]

config :bonfire_data_access_control, Acl,
  [code: quote do
    has_one :named, unquote(Named), foreign_key: :id
    has_one :caretaker, unquote(Caretaker), foreign_key: :id
  end]

config :bonfire_data_access_control, Circle,
  [code: quote do
    has_one :caretaker, unquote(Caretaker), foreign_key: :id
    has_one :named, unquote(Named), foreign_key: :id
  end]

config :bonfire_data_access_control, Controlled, []
config :bonfire_data_access_control, Encircle, []
config :bonfire_data_access_control, Grant, []
config :bonfire_data_access_control, Interact, []
config :bonfire_data_access_control, Verb, []

# bonfire_data_activity_pub

config :bonfire_data_activity_pub, Actor,
  [code: quote do
    belongs_to :character, unquote(Character), foreign_key: :id, define_field: false
    has_one :peered, unquote(Peered), references: :id, foreign_key: :id
    belongs_to :user, unquote(User), foreign_key: :id, define_field: false
  end]

config :bonfire_data_activity_pub, Peer, []
config :bonfire_data_activity_pub, Peered, []

# bonfire_data_identity

config :bonfire_data_identity, Account,
  [code: quote do
    has_one :credential, unquote(Credential),foreign_key: :id
    has_one :email, unquote(Email), foreign_key: :id
    has_one :inbox, unquote(Inbox), foreign_key: :id
    many_to_many :users, unquote(User), join_through: "bonfire_data_identity_accounted", join_keys: [account_id: :id, id: :id]
    many_to_many :shared_users, unquote(User), join_through: "bonfire_data_shared_user_accounts", join_keys: [account_id: :id, shared_user_id: :id]
  end]

config :bonfire_data_identity, Accounted,
  [code: quote do
    belongs_to :user, unquote(User), foreign_key: :id, define_field: false
  end]

config :bonfire_data_identity, Caretaker, []

config :bonfire_data_identity, Character,
  [code: quote do
    @follow_ulid "70110WTHE1EADER1EADER1EADE"
    has_one :peered, unquote(Peered), references: :id, foreign_key: :id
    has_one :actor, unquote(Actor), foreign_key: :id
    has_one :profile, unquote(Profile), foreign_key: :id
    has_one :user, unquote(User), foreign_key: :id
    has_one :feed, unquote(Feed), foreign_key: :id
    has_one :inbox, unquote(Inbox), foreign_key: :id
    has_many :feed_publishes, unquote(FeedPublish), references: :id, foreign_key: :feed_id
    has_many :followers, unquote(Follow), foreign_key: :following_id, references: :id
    has_many :followed, unquote(Follow), foreign_key: :follower_id, references: :id
    has_one :follow_count, unquote(EdgeTotal), foreign_key: :id, references: :id, where: [table_id: @follow_ulid]
  end]

config :bonfire_data_identity, Credential,
  [code: quote do
    belongs_to :account, unquote(Account), foreign_key: :id, define_field: false
  end]

config :bonfire_data_identity, Email,
  [must_confirm: true,
   code: quote do
     belongs_to :account, unquote(Account), foreign_key: :id, define_field: false
   end]

config :bonfire_data_identity, Self, []

config :bonfire_data_identity, User,
  [code: quote do
    has_one  :accounted, unquote(Accounted), foreign_key: :id
    has_one  :profile, unquote(Profile), foreign_key: :id
    has_one  :character, unquote(Character), foreign_key: :id
    has_one  :actor, unquote(Actor), foreign_key: :id
    has_one  :instance_admin, unquote(InstanceAdmin), foreign_key: :id
    has_one  :self, unquote(Self), foreign_key: :id
    has_one  :peered, unquote(Peered), references: :id
    has_many :encircles, unquote(Encircle), foreign_key: :subject_id
    # has_one  :shared_user, unquote(Bonfire.Data.SharedUser), foreign_key: :id
    has_many :created, unquote(Created), foreign_key: :creator_id
    has_many :creations, through: [:created, :pointer]
    has_many :posts, through: [:created, :post]
    has_many :user_activities, unquote(Activity), foreign_key: :subject_id, references: :id
    many_to_many :caretaker_accounts, unquote(Account),
      join_through: "bonfire_data_shared_user_accounts", join_keys: [shared_user_id: :id, account_id: :id]
    # has_many :account, through: [:accounted, :account] # this is private info, do not expose
    # has_one :geolocation, Bonfire.Geolocate.Geolocation
  end]

# bonfire_data_social

config :bonfire_data_social, Activity,
  [code: quote do
    @like_ulid   "11KES11KET0BE11KEDY0VKN0WS"
    @boost_ulid  "300STANN0VNCERESHARESH0VTS"
    @follow_ulid "70110WTHE1EADER1EADER1EADE"
    # has_one :object_created, unquote(Created), foreign_key: :id
    # belongs_to :object_peered, unquote(Peered), foreign_key: :id, define_field: false
    # belongs_to :object_post, unquote(Post), foreign_key: :id, define_field: false
    # belongs_to :object_post_content, unquote(PostContent), foreign_key: :id, define_field: false
    # belongs_to :object_message, unquote(Message), foreign_key: :id, define_field: false
    has_one :replied, unquote(Replied), foreign_key: :id
    # has_one:    [reply_to: {[through: [:replied, :reply_to]]}],
    # has_one:    [reply_to_post: {[through: [:replied, :reply_to_post]]}],
    # has_one:    [reply_to_post_content: {[through: [:replied, :reply_to_post_content]]}],
    # has_one:    [reply_to_creator_character: {[through: [:replied, :reply_to_creator_character]]}],
    # has_one:    [reply_to_creator_profile: {[through: [:replied, :reply_to_creator_profile]]}],
    # has_one:    [thread_post: {[through: [:replied, :thread_post]]}],
    # has_one:    [thread_post_content: {[through: [:replied, :thread_post_content]]}],
    # has_one:    [object_creator_user: {[through: [:object_created, :creator_user]]}],
    # has_one:    [object_creator_character: {[through: [:object_created, :creator_character]]}],
    # has_one:    [object_creator_profile: {[through: [:object_created, :creator_profile]]}],
    has_one :controlled, unquote(Controlled), foreign_key: :id, references: :id
    # ugly workaround needed for querying
    has_one :activity, unquote(Activity), foreign_key: :id, references: :id
    has_one :like_count, unquote(EdgeTotal), foreign_key: :id, references: :id, where: [table_id: @like_ulid]
    has_one :boost_count, unquote(EdgeTotal), foreign_key: :id, references: :id, where: [table_id: @boost_ulid]
    has_one :follow_count, unquote(EdgeTotal), foreign_key: :id, references: :id, where: [table_id: @follow_ulid]

    many_to_many :tags, Bonfire.Tag,
      join_through: "bonfire_tagged", unique: true,
      join_keys: [pointer_id: :id, tag_id: :id], on_replace: :delete
  end]

config :bonfire_data_social, Edge, []

config :bonfire_data_social, Feed,
  [code: quote do
    belongs_to :character, unquote(Character), foreign_key: :id, define_field: false
    belongs_to :user, unquote(User), foreign_key: :id, define_field: false
  end]

config :bonfire_data_social, FeedPublish, []

config :bonfire_data_social, Follow,
  [code: quote do
    has_one :edge, unquote(Edge), foreign_key: :id
  end]
  # belongs_to: [follower_character: {Character, foreign_key: :follower_id, define_field: false}],
  # belongs_to: [follower_profile: {Profile, foreign_key: :follower_id, define_field: false}],
  # belongs_to: [followed_character: {Character, foreign_key: :followed_id, define_field: false}],
  # belongs_to: [followed_profile: {Profile, foreign_key: :followed_id, define_field: false}]

config :bonfire_data_social, Block,
  [code: quote do
    has_one :edge, unquote(Edge), foreign_key: :id
  end]

config :bonfire_data_social, Boost,
  [code: quote do
    has_one :edge, unquote(Edge), foreign_key: :id
  end]
  # has_one:  [activity: {Activity, foreign_key: :object_id, references: :boosted_id}] # requires an ON clause

config :bonfire_data_social, Like,
  [code: quote do
    has_one :edge, unquote(Edge), foreign_key: :id
  end]
  # has_one:  [activity: {Activity, foreign_key: :object_id, references: :liked_id}] # requires an ON clause

config :bonfire_data_social, Flag,
  [code: quote do
    has_one :edge, unquote(Edge), foreign_key: :id
  end]

config :bonfire_data_social, Bookmark, []

config :bonfire_data_social, Message,
  [code: quote do
    @like_ulid  "11KES11KET0BE11KEDY0VKN0WS"
    @boost_ulid "300STANN0VNCERESHARESH0VTS"
    has_one  :post_content, unquote(PostContent), foreign_key: :id
    has_one  :created, unquote(Created), foreign_key: :id
    has_one  :peered, unquote(Peered), references: :id, foreign_key: :id
    has_many :activities, unquote(Activity), foreign_key: :object_id, references: :id
    has_one  :activity, unquote(Activity), foreign_key: :object_id, references: :id # requires an ON clause
    has_one  :replied, unquote(Replied), foreign_key: :id
    has_many :direct_replies, unquote(Replied), foreign_key: :reply_to_id
    has_one :controlled, unquote(Controlled), foreign_key: :id
    has_one :like_count, unquote(EdgeTotal), foreign_key: :id, references: :id, where: [table_id: @like_ulid]
    has_one :boost_count, unquote(EdgeTotal), foreign_key: :id, references: :id, where: [table_id: @boost_ulid]
  end]

config :bonfire_data_social, Mention, []
config :bonfire_data_social, Named, []

config :bonfire_data_social, Post,
  [code: quote do
    @like_ulid  "11KES11KET0BE11KEDY0VKN0WS"
    @boost_ulid "300STANN0VNCERESHARESH0VTS"
    has_one :post_content, unquote(PostContent), foreign_key: :id
    has_one :created, unquote(Created), foreign_key: :id
    has_one :peered, unquote(Peered), references: :id, foreign_key: :id
    # has_one:  [creator_user: {[through: [:created, :creator_user]]}],
    # has_one:  [creator_character: {[through: [:created, :creator_character]]}],
    # has_one:  [creator_profile: {[through: [:created, :creator_profile]]}],
    has_many :activities, unquote(Activity), foreign_key: :object_id, references: :id
    has_one :activity, unquote(Activity), foreign_key: :object_id, references: :id # requires an ON clause
    has_one :replied, unquote(Replied), foreign_key: :id
    # has_one:  [reply_to: {[through: [:replied, :reply_to]]}],
    # has_one:  [reply_to_post: {[through: [:replied, :reply_to_post]]}],
    # has_one:  [reply_to_post_content: {[through: [:replied, :reply_to_post_content]]}],
    # has_one:  [reply_to_creator_character: {[through: [:replied, :reply_to_creator_character]]}],
    # has_one:  [reply_to_creator_profile: {[through: [:replied, :reply_to_creator_profile]]}],
    has_many :direct_replies, unquote(Replied), foreign_key: :reply_to_id
    # has_one:  [thread_post: {[through: [:replied, :thread_post]]}],
    # has_one:  [thread_post_content: {[through: [:replied, :thread_post_content]]}],
    has_one :controlled, unquote(Controlled), foreign_key: :id
    has_one :like_count, unquote(EdgeTotal), foreign_key: :id, references: :id, where: [table_id: @like_ulid]
    has_one :boost_count, unquote(EdgeTotal), foreign_key: :id, references: :id, where: [table_id: @boost_ulid]
  end]

config :bonfire_data_social, PostContent, []

config :bonfire_data_social, Replied,
  [code: quote do
    @like_ulid  "11KES11KET0BE11KEDY0VKN0WS"
    @boost_ulid "300STANN0VNCERESHARESH0VTS"
    belongs_to :post, unquote(Post), foreign_key: :id, define_field: false
    belongs_to :post_content,unquote(PostContent), foreign_key: :id, define_field: false
    has_many :activities, unquote(Activity), foreign_key: :object_id, references: :id
    has_one :activity, unquote(Activity), foreign_key: :object_id, references: :id
    has_one :reply_to_post, unquote(Post), foreign_key: :id, references: :reply_to_id
    has_one :reply_to_post_content, unquote(PostContent), foreign_key: :id, references: :reply_to_id
    has_one :reply_to_created, unquote(Created), foreign_key: :id, references: :reply_to_id
    # has_one  :reply_to_creator_user, through: [:reply_to_created, :creator_user]
    # has_one  :reply_to_creator_character, through: [:reply_to_created, :creator_character]
    # has_one  :reply_to_creator_profile, through: [:reply_to_created, :creator_profile]
    has_many :direct_replies, unquote(Replied), foreign_key: :reply_to_id, references: :id
    has_many :thread_replies, unquote(Replied), foreign_key: :thread_id, references: :id
    has_one :thread_post, unquote(Post), foreign_key: :id, references: :thread_id
    has_one :thread_post_content, unquote(PostContent), foreign_key: :id, references: :thread_id
    has_one :controlled, unquote(Controlled), foreign_key: :id, references: :id
    has_one :like_count, unquote(EdgeTotal), foreign_key: :id, references: :id, where: [table_id: @like_ulid]
    has_one :boost_count, unquote(EdgeTotal), foreign_key: :id, references: :id, where: [table_id: @boost_ulid]
  end]

config :bonfire_data_social, Created,
  [code: quote do
    belongs_to :creator_user, unquote(User), foreign_key: :creator_id, define_field: false
    belongs_to :creator_character, unquote(Character), foreign_key: :creator_id, define_field: false
    belongs_to :creator_profile, unquote(Profile), foreign_key: :creator_id, define_field: false
    has_one :peered, unquote(Peered), foreign_key: :id, references: :id
    has_one :post, unquote(Post), foreign_key: :id, references: :id
  end]

config :bonfire_data_social, Profile,
  [code: quote do
    belongs_to :user, unquote(User), foreign_key: :id, define_field: false
    has_one :controlled, unquote(Controlled), foreign_key: :id, references: :id
  end]
######### other extensions

# optional mixin relations for tags that are characters (eg Category) or any other type of objects
config :bonfire_tag, Bonfire.Tag,
  [code: quote do
    @like_ulid "11KES11KET0BE11KEDY0VKN0WS"
    # for objects that are follow-able and can federate activities
    has_one :character, unquote(Character), references: :id, foreign_key: :id
    has_one :peered, unquote(Peered), references: :id, foreign_key: :id
    # has_one: [actor:        {Bonfire.Data.ActivityPub.Actor,     references: :id, foreign_key: :id}],
    # name/description
    has_one :profile, unquote(Profile), references: :id, foreign_key: :id
    # for taxonomy categories/topics
    has_one :category, unquote(Category), references: :id, foreign_key: :id
    # for locations
    has_one :geolocation, unquote(Geolocation), references: :id, foreign_key: :id
    has_one :like_count, unquote(EdgeTotal), foreign_key: :id, references: :id, where: [table_id: @like_ulid]
  end]

# add references of tagged objects to any Category
config :bonfire_classify, Category,
  [code: quote do
    many_to_many :tags, unquote(Bonfire.Tag),
      join_through: "bonfire_tagged",
      unique: true,
      join_keys: [tag_id: :id, pointer_id: :id],
      on_replace: :delete
  end]

config :bonfire_files, Media,
  [code: quote do
    field :url, :string, virtual: true
  end]
