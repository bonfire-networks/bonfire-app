import Config

#### Base configuration

verbs = ["Boost", "Create", "Delete", "Edit", "Flag", "Follow", "Like", "Mention",
 "Message", "Read", "Reply", "Request", "See", "Tag"]

# Choose password hashing backend
# Note that this corresponds with our dependencies in mix.exs
hasher = if config_env() in [:dev, :test], do: Pbkdf2, else: Argon2

config :bonfire_data_identity, Bonfire.Data.Identity.Credential,
  hasher_module: hasher

#### Sentinel Data Services

# Search these apps/extensions for Pointable ecto schema definitions to index
pointable_schema_extensions = [
    :bonfire,
    :bonfire_data_access_control,
    :bonfire_data_activity_pub,
    :bonfire_data_identity,
    :bonfire_data_social,
    :bonfire_data_edges,
    :bonfire_tag,
    :bonfire_classify,
    :bonfire_data_shared_users,
    :bonfire_files,
    :bonfire_quantify,
    :bonfire_geolocate,
    :bonfire_valueflows,
    :bonfire_valueflows_observe,
  ]
config :pointers, :search_path, pointable_schema_extensions

# Search these apps/extensions for context or queries modules to index (i.e. they contain modules with a queries_module/0 or context_modules/0 function)
context_and_queries_extensions = pointable_schema_extensions ++ [
    :bonfire_common,
    :bonfire_me,
    :bonfire_social,
  ]

extensions_with_config = context_and_queries_extensions ++ [
    :bonfire_boundaries,
    :bonfire_federate_activitypub,
    :bonfire_search,
    :bonfire_mailer,
    :bonfire_geolocate
  ]

config :bonfire, :verb_names, verbs
config :bonfire, :context_modules_search_path, context_and_queries_extensions
config :bonfire, :query_modules_search_path, context_and_queries_extensions
config :bonfire, :config_modules_search_path, extensions_with_config

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
  Acl, Circle, Encircle, Controlled, InstanceAdmin, Grant, Verb,
}
alias Bonfire.Data.ActivityPub.{Actor, Peer, Peered}
alias Bonfire.Boundaries.{Permitted, Stereotyped}
alias Bonfire.Data.Edges.{Edge,EdgeTotal}
alias Bonfire.Data.Identity.{
  Account, Accounted, AuthSecondFactor, Caretaker, CareClosure, Character, Credential, Email, ExtraInfo, Named, Self, Settings, User,
}
alias Bonfire.Data.Social.{
  Activity, APActivity, Article, Block, Bookmark, Boost, Created, Feed, FeedPublish,
  Flag, Follow, Like, Mention, Message, Post, PostContent, Profile, Replied, Request,
}
alias Bonfire.Classify.Category
alias Bonfire.Geolocate.Geolocation
alias Bonfire.Files
alias Bonfire.Files.Media
alias Bonfire.{Tag, Tag.Tagged}

#### Flexto Stitching

## WARNING: This is the flaky magic bit. We use configuration to
## compile extra stuff into modules.  If you add new fields or
## relations to ecto models in a dependency, you must recompile that
## dependency for it to show up! You will probably find you need to
## `rm -Rf _build/*/lib/bonfire_data_*` a lot.

mixin = [foreign_key: :id, references: :id]

common_assocs = %{
  ### Mixins

  # A summary of an object that can appear in a feed.
  activity:     quote(do: has_one(:activity,     unquote(Activity),    unquote(mixin))),
  # ActivityPub actor information
  actor:        quote(do: has_one(:actor,        unquote(Actor),       unquote(mixin))),
  # Indicates the entity responsible for an activity. Sort of like creator, but transferrable. Used
  # during deletion - when the caretaker is deleted, all their stuff will be too.
  caretaker:    quote(do: has_one(:caretaker,    unquote(Caretaker),   unquote(mixin))),
  # A Character has a unique username and some feeds.
  character:    quote(do: has_one(:character,    unquote(Character),   unquote(mixin))),
  # Indicates the creator of an object
  created:      quote(do: has_one(:created,      unquote(Created),     unquote(mixin))),
  # Used for non-textual interactions such as likes and follows to indicate the other object.
  edge:         quote(do: has_one(:edge,         unquote(Edge),        unquote(mixin))),
  # Adds a name that can appear in the user interface for an object. e.g. for an ACL.
  named:        quote(do: has_one(:named,        unquote(Named),       unquote(mixin))),
  # Adds extra info that can appear in the user interface for an object. e.g. a summary or JSON-encoded data.
  extra_info:   quote(do: has_one(:extra_info,   unquote(ExtraInfo),   unquote(mixin))),
  # Information about the remote instance the object is from, if it is not local.
  peered:       quote(do: has_one(:peered,       unquote(Peered),      unquote(mixin))),
  # Information about the content of posts, e.g. a scrubbed html body
  post_content: quote(do: has_one(:post_content, unquote(PostContent), unquote(mixin))),
  # Information about a user or other object that they wish to make available
  profile:      quote(do: has_one(:profile,      unquote(Profile),     unquote(mixin))),
  # Threading information, for threaded discussions.
  replied:      quote(do: has_one(:replied,      unquote(Replied),     unquote(mixin))),
  # Information that allows the system to identify special system-managed ACLS.
  stereotyped:  quote(do: has_one(:stereotyped,  unquote(Stereotyped), unquote(mixin))),


  ### Multimixins

  # Links to access control information for this object.
  controlled:     quote(do: has_many(:controlled,     unquote(Controlled),  unquote(mixin))),
  # Inserts the object into selected feeds.
  feed_publishes: quote(do: has_many(:feed_publishes, unquote(FeedPublish), unquote(mixin))),

  # Information that this object has some files
  files:          quote(do: has_many(:files,          unquote(Files),       unquote(mixin))),
  # The actual files
  media:          quote(do: many_to_many(:media, unquote(Media), join_through: unquote(Files), unique: true, join_keys: [id: :id, media_id: :id], on_replace: :delete)),

  # Information that this object tagged other objects.
  tagged:         quote(do: has_many(:tagged,         unquote(Tagged),      unquote(mixin))),
  # The actual tags
  tags:           quote(do: many_to_many(:tags, unquote(Pointer), join_through: unquote(Tagged), unique: true, join_keys: [id: :id, tag_id: :id], on_replace: :delete)),


  ### Regular has_many associations

  # The objects which reply to this object.
  direct_replies: quote(do: has_many(:direct_replies, unquote(Replied),     foreign_key: :reply_to_id)),
  # A recursive view of caretakers of caretakers of... used during deletion.
  care_closure:   quote(do: has_many(:care_closure,   unquote(CareClosure), foreign_key: :branch_id)),
  # Retrieves activities where we are the object. e.g. if we are a
  # post or a user, this could turn up activities from likes or follows.
  activities:     quote(do: has_many(:activities,     unquote(Activity),    foreign_key: :object_id, references: :id)),

  ### Stuff I'm not sure how to categorise yet

  # Used currently only for requesting to follow a user, but more general
  request: quote(do: has_one(:request, unquote(Request), unquote(mixin))),
}

# retrieves a list of quoted forms suitable for use with unquote_splicing
common = fn names ->
  for name <- List.wrap(names) do
    with nil <- common_assocs[name],
      do: raise(RuntimeError, message: "Expected a common association name, got #{inspect(name)}")
  end
end

edge  = common.([:controlled, :activities, :request, :created])
edges = common.([:controlled, :activities, :request, :created, :caretaker, :activity, :feed_publishes])

# first up, pointers could have all the mixins we're using. TODO

pointer_mixins = common.([
  :activity, :actor, :caretaker, :character, :created, :edge,
  :named, :extra_info, :peered, :post_content, :profile, :replied, :stereotyped
])
config :pointers, Pointer,
  [code: quote do
    @like_ulid   "11KES11KET0BE11KEDY0VKN0WS"
    @boost_ulid  "300STANN0VNCERESHARESH0VTS"
    @follow_ulid "70110WTHE1EADER1EADER1EADE"
    field :dummy, :any, virtual: true
    # pointables
    has_one :circle, unquote(Circle), foreign_key: :id
    many_to_many :encircle_subjects, Pointer, join_through: Encircle, join_keys: [circle_id: :id, subject_id: :id]
    has_one :permitted, unquote(Permitted), foreign_key: :object_id
    has_one :user, unquote(User), foreign_key: :id
    has_one :post, unquote(Post), foreign_key: :id
    has_one :message, unquote(Message), foreign_key: :id
    has_one :category, unquote(Category), foreign_key: :id
    has_one :geolocation, unquote(Geolocation), foreign_key: :id
    # mixins
    unquote_splicing(pointer_mixins)
    # multimixins
    unquote_splicing(common.([:controlled, :tagged, :tags, :files, :media]))
    # has_many
    unquote_splicing(common.([:activities, :care_closure, :direct_replies, :feed_publishes]))

    ## special things
    # these should go away in future and they should be populated by a single query.
    has_one :like_count, unquote(EdgeTotal), foreign_key: :id, references: :id,
      where: [table_id: @like_ulid]
    has_one :boost_count, unquote(EdgeTotal), foreign_key: :id, references: :id,
      where: [table_id: @boost_ulid]
    has_one :follow_count, unquote(EdgeTotal), foreign_key: :id, references: :id,
      where: [table_id: @follow_ulid]

  end]

config :pointers, Table, []

# now let's weave everything else together for convenience

# bonfire_data_access_control

config :bonfire_data_access_control, Acl,
  [code: quote do
    field :grants_count, :integer, virtual: true
    field :controlled_count, :integer, virtual: true
    # mixins
    unquote_splicing(common.([:caretaker, :named, :extra_info, :stereotyped]))
    # multimixins
    # unquote_splicing(common.([:controlled]))
  end]

config :bonfire_data_access_control, Circle,
  [code: quote do
    field :encircles_count, :integer, virtual: true
    # mixins
    unquote_splicing(common.([:caretaker, :named, :extra_info, :stereotyped]))
    # multimixins
    unquote_splicing(common.([:controlled]))
  end]

config :bonfire_data_access_control, Controlled, []

config :bonfire_data_access_control, Encircle,
  [code: quote do
    has_one :peer, unquote(Peer), foreign_key: :id, references: :subject_id
  end]

config :bonfire_data_access_control, Grant,
  [code: quote do
    # mixins
    unquote_splicing(common.([:caretaker]))
    # multimixins
    # unquote_splicing(common.([:controlled]))
  end]

config :bonfire_data_access_control, Verb, []

config :bonfire_boundaries, Stereotyped,
  [code: quote do
    has_one(:named,        unquote(Named),       [foreign_key: :id, references: :stereotype_id])
  end]

# bonfire_data_activity_pub

config :bonfire_data_activity_pub, Actor,
  [code: quote do
    # hacks
    belongs_to :character,  unquote(Character),  foreign_key: :id, define_field: false
    belongs_to :user,       unquote(User),       foreign_key: :id, define_field: false
    # mixins
    unquote_splicing(common.([:peered]))
    # multimixins
    unquote_splicing(common.([:controlled]))
  end]

config :bonfire_data_activity_pub, Peer, []
config :bonfire_data_activity_pub, Peered, []

# bonfire_data_identity

config :bonfire_data_identity, Account,
  [code: quote do
    has_one :credential, unquote(Credential),foreign_key: :id
    has_one :email, unquote(Email), foreign_key: :id
    has_one :auth_second_factor, unquote(AuthSecondFactor), foreign_key: :id
    has_one :settings, unquote(Settings), foreign_key: :id
    many_to_many :users, unquote(User),
      join_through: Accounted,
      join_keys: [account_id: :id, id: :id]
    many_to_many :shared_users, unquote(User), # optional
      join_through: "bonfire_data_shared_user_accounts",
      join_keys: [account_id: :id, shared_user_id: :id]
  end]

config :bonfire_data_identity, Accounted,
  [code: quote do
    belongs_to :user, unquote(User), foreign_key: :id, define_field: false
  end]

config :bonfire_data_identity, Caretaker,
  [code: quote do
    has_one :user, unquote(User), foreign_key: :id, references: :caretaker_id
    # mixins
    unquote_splicing(common.([:character, :profile]))
  end]

config :bonfire_data_identity, Character,
  [code: quote do
    @follow_ulid "70110WTHE1EADER1EADER1EADE"
    # mixins
    unquote_splicing(common.([:actor, :peered, :profile]))
    has_one :user, unquote(User), unquote(mixin)
    has_one :feed, unquote(Feed), unquote(mixin)
    has_many :followers, unquote(Follow), foreign_key: :following_id, references: :id
    has_many :followed, unquote(Follow), foreign_key: :follower_id, references: :id
    has_one :follow_count, unquote(EdgeTotal), foreign_key: :id, references: :id,
      where: [table_id: @follow_ulid]
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
    @like_ulid   "11KES11KET0BE11KEDY0VKN0WS"
    @boost_ulid  "300STANN0VNCERESHARESH0VTS"
    @follow_ulid "70110WTHE1EADER1EADER1EADE"
    # mixins
    has_one  :accounted, unquote(Accounted), foreign_key: :id
    has_one  :instance_admin, unquote(InstanceAdmin), foreign_key: :id, on_replace: :update
    has_one  :self, unquote(Self), foreign_key: :id
    has_one  :shared_user, unquote(Bonfire.Data.SharedUser), foreign_key: :id
    has_one  :settings, unquote(Settings), foreign_key: :id
    unquote_splicing(common.([:actor, :character, :created, :peered, :profile]))
    # multimixins
    unquote_splicing(common.([:controlled]))
    # manies
    has_many :encircles, unquote(Encircle), foreign_key: :subject_id
    has_many :creations, through: [:created, :pointer] # todo: stop through
    has_many :posts, through: [:created, :post] # todo: stop through
    has_many :followers, unquote(Edge), foreign_key: :object_id, references: :id, where: [table_id: @follow_ulid]
    has_many :followed, unquote(Edge), foreign_key: :subject_id, references: :id, where: [table_id: @follow_ulid]
    has_many :user_activities, unquote(Activity), foreign_key: :subject_id, references: :id
    has_many :boost_activities, unquote(Edge), foreign_key: :subject_id, references: :id, where: [table_id: @boost_ulid]
    has_many :like_activities, unquote(Edge), foreign_key: :subject_id, references: :id, where: [table_id: @like_ulid]
    many_to_many :caretaker_accounts, unquote(Account),
      join_through: "bonfire_data_shared_user_accounts",
      join_keys: [shared_user_id: :id, account_id: :id]
    # has_many :account, through: [:accounted, :account] # this is private info, do not expose
    # has_one :geolocation, Bonfire.Geolocate.Geolocation # enable if using Geolocate extension
  end]

config :bonfire_data_identity, Named, []
config :bonfire_data_identity, ExtraInfo, []

### bonfire_data_social

config :bonfire_data_social, Activity,
  [code: quote do
    @like_ulid   "11KES11KET0BE11KEDY0VKN0WS"
    @boost_ulid  "300STANN0VNCERESHARESH0VTS"
    @follow_ulid "70110WTHE1EADER1EADER1EADE"
    has_many :feed_publishes, unquote(FeedPublish), unquote(mixin)
    has_one :seen, unquote(Edge), foreign_key: :object_id, references: :id
    # ugly workaround needed for certain queries (TODO: check if still needed)
    has_one :activity, unquote(Activity), foreign_key: :id, references: :id
    # mixins linked to the object rather than the activity:
    has_one :created, unquote(Created), foreign_key: :id, references: :object_id
    has_one :replied, unquote(Replied), foreign_key: :id, references: :object_id
    field :path, EctoMaterializedPath.ULIDs, virtual: true
    has_one :like_count, unquote(EdgeTotal), foreign_key: :id, references: :object_id, where: [table_id: @like_ulid]
    has_one :boost_count, unquote(EdgeTotal), foreign_key: :id, references: :object_id, where: [table_id: @boost_ulid]
    has_one :follow_count, unquote(EdgeTotal), foreign_key: :id, references: :object_id, where: [table_id: @follow_ulid]
    has_many :controlled, unquote(Controlled), foreign_key: :id, references: :object_id
    has_many :tagged, unquote(Tagged), foreign_key: :id, references: :object_id
    many_to_many :tags, unquote(Pointer),
      join_through: unquote(Tagged),
      unique: true,
      join_keys: [id: :object_id, tag_id: :id],
      on_replace: :delete
    has_many :files, unquote(Files), foreign_key: :id, references: :object_id
    many_to_many :media, unquote(Media),
      join_through: unquote(Files),
      unique: true,
      join_keys: [id: :object_id, media_id: :id],
      on_replace: :delete
  end]

config :bonfire_data_social, APActivity,
  [code: quote do
    unquote_splicing(common.([:activity, :caretaker, :controlled]))
  end]

config :bonfire_data_edges, Edge,
  [code: quote do
    unquote_splicing(edge)
    # TODO: requires composite foreign keys:
    # has_one :activity, unquote(Activity),
    #   foreign_key: [:table_id, :object_id], references: [:table_id, :object_id]
  end]

config :bonfire_data_social, Feed,
  [code: quote do
    # mixins
    unquote_splicing(common.([:activity, :caretaker]))
    # belongs_to :character, unquote(Character), foreign_key: :id, define_field: false
    # belongs_to :user, unquote(User), foreign_key: :id, define_field: false
  end]

config :bonfire_data_social, FeedPublish,
 [code: quote do
    field :dummy, :any, virtual: true
    has_one :activity, unquote(Activity), foreign_key: :object_id, references: :id
    # belongs_to :character, unquote(Character), foreign_key: :id, define_field: false
    # belongs_to :user, unquote(User), foreign_key: :id, define_field: false
  end]


config :bonfire_data_social, Follow,
  [code: quote do
    unquote_splicing(edges)
  end]
  # belongs_to: [follower_character: {Character, foreign_key: :follower_id, define_field: false}],
  # belongs_to: [follower_profile: {Profile, foreign_key: :follower_id, define_field: false}],
  # belongs_to: [followed_character: {Character, foreign_key: :followed_id, define_field: false}],
  # belongs_to: [followed_profile: {Profile, foreign_key: :followed_id, define_field: false}]

config :bonfire_data_social, Block,
  [code: quote do
    unquote_splicing(edges)
  end]

config :bonfire_data_social, Boost,
  [code: quote do
    unquote_splicing(edges)
  end]
  # has_one:  [activity: {Activity, foreign_key: :object_id, references: :boosted_id}] # requires an ON clause

config :bonfire_data_social, Like,
  [code: quote do
    unquote_splicing(edges)
  end]
  # has_one:  [activity: {Activity, foreign_key: :object_id, references: :liked_id}] # requires an ON clause

config :bonfire_data_social, Flag,
  [code: quote do
    unquote_splicing(edges)
  end]

config :bonfire_data_social, Request,
  [code: quote do
    unquote_splicing(edges)
  end]

config :bonfire_data_social, Bookmark,
  [code: quote do
    unquote_splicing(edges)
  end]

config :bonfire_data_social, Message,
  [code: quote do
    @like_ulid  "11KES11KET0BE11KEDY0VKN0WS"
    @boost_ulid "300STANN0VNCERESHARESH0VTS"
    # mixins
    unquote_splicing(common.([:activity, :caretaker, :created, :peered, :post_content, :replied]))
    # multimixins
    unquote_splicing(common.([:controlled, :feed_publishes, :tagged, :tags, :files, :media]))
    # has
    unquote_splicing(common.([:direct_replies]))
    # special
    has_one :like_count, unquote(EdgeTotal), foreign_key: :id, references: :id, where: [table_id: @like_ulid]
    has_one :boost_count, unquote(EdgeTotal), foreign_key: :id, references: :id, where: [table_id: @boost_ulid]
  end]

config :bonfire_data_social, Mention, []

config :bonfire_data_social, Post,
  [code: quote do
    @like_ulid  "11KES11KET0BE11KEDY0VKN0WS"
    @boost_ulid "300STANN0VNCERESHARESH0VTS"
    # mixins
    unquote_splicing(common.([:activities, :activity, :caretaker, :created, :peered, :post_content, :replied]))
    # multimixins
    unquote_splicing(common.([:controlled, :tagged, :tags, :files, :media, :feed_publishes]))
    # has
    unquote_splicing(common.([:direct_replies]))
    # special
    has_one :permitted, unquote(Permitted), foreign_key: :object_id
    # has_one:  [creator_user: {[through: [:created, :creator_user]]}],
    # has_one:  [creator_character: {[through: [:created, :creator_character]]}],
    # has_one:  [creator_profile: {[through: [:created, :creator_profile]]}],
    # has_one :activity, unquote(Activity), foreign_key: :object_id, references: :id # requires an ON clause
    # has_one:  [reply_to: {[through: [:replied, :reply_to]]}],
    # has_one:  [reply_to_post: {[through: [:replied, :reply_to_post]]}],
    # has_one:  [reply_to_post_content: {[through: [:replied, :reply_to_post_content]]}],
    # has_one:  [reply_to_creator_character: {[through: [:replied, :reply_to_creator_character]]}],
    # has_one:  [reply_to_creator_profile: {[through: [:replied, :reply_to_creator_profile]]}],
    # has_one:  [thread_post: {[through: [:replied, :thread_post]]}],
    # has_one:  [thread_post_content: {[through: [:replied, :thread_post_content]]}],
    has_one :like_count, unquote(EdgeTotal),
      references: :id, foreign_key: :id, where: [table_id: @like_ulid]
    has_one :boost_count, unquote(EdgeTotal),
      references: :id, foreign_key: :id, where: [table_id: @boost_ulid]
  end]


config :bonfire_data_social, PostContent,
  [code: quote do
    # mixins
    unquote_splicing(common.([:created]))
    # multimixins
    unquote_splicing(common.([:controlled]))
    # virtuals for changesets
    field :hashtags, {:array, :any}, virtual: true
    field :mentions, {:array, :any}, virtual: true
    field :urls, {:array, :any}, virtual: true
  end]

config :bonfire_data_social, Replied,
  [code: quote do
    # multimixins - shouldn't be here really
    unquote_splicing(common.([:controlled]))

    @like_ulid  "11KES11KET0BE11KEDY0VKN0WS"
    @boost_ulid "300STANN0VNCERESHARESH0VTS"
    belongs_to :post, unquote(Post), foreign_key: :id, define_field: false
    belongs_to :post_content,unquote(PostContent), foreign_key: :id, define_field: false
    has_one :activity, unquote(Activity), foreign_key: :object_id, references: :id
    field :replying_to, :map, virtual: true # used in changesets
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
    has_one :like_count, unquote(EdgeTotal), foreign_key: :id, references: :id,
      where: [table_id: @like_ulid]
    has_one :boost_count, unquote(EdgeTotal), foreign_key: :id, references: :id,
      where: [table_id: @boost_ulid]
  end]

config :bonfire_data_social, Created,
  [code: quote do
    belongs_to :creator_user, unquote(User), foreign_key: :creator_id, define_field: false
    belongs_to :creator_character, unquote(Character), foreign_key: :creator_id, define_field: false
    belongs_to :creator_profile, unquote(Profile), foreign_key: :creator_id, define_field: false
    # mixins - shouldn't be here really
    unquote_splicing(common.([:peered]))
    has_one :post, unquote(Post), unquote(mixin) # huh?
  end]

config :bonfire_data_social, Profile,
  [code: quote do
    belongs_to :user, unquote(User), foreign_key: :id, define_field: false
    # multimixins - shouldn't be here really
    unquote_splicing(common.([:controlled]))
  end]

######### other extensions

config :bonfire_files, Media,
  [code: quote do
    field :url, :string, virtual: true
    # multimixins - shouldn't be here really
    unquote_splicing(common.([:controlled]))
  end]

config :bonfire_classify, Category,
  [code: quote do
    # mixins
    unquote_splicing(common.([:activity, :created, :actor, :peered, :profile, :character])) # TODO :caretaker
    # multimixins
    unquote_splicing(common.([:controlled, :feed_publishes]))

    has_one(:creator, through: [:created, :creator])

  # add references of tagged objects to any Category
    many_to_many :tags, unquote(Pointer),
      join_through: unquote(Tagged),
      unique: true,
      join_keys: [tag_id: :id, id: :id],
      on_replace: :delete
  end]

config :bonfire_geolocate, Bonfire.Geolocate.Geolocation,
  [code: quote do
    # mixins
    unquote_splicing(common.([:activity, :caretaker, :created, :actor, :peered, :profile, :character]))
    # multimixins
    unquote_splicing(common.([:controlled, :tagged, :tags, :feed_publishes]))
  end]

config :bonfire_valueflows, ValueFlows.EconomicEvent,
  [code: quote do
    # mixins
    unquote_splicing(common.([:activity, :caretaker, :peered, :replied])) # TODO :caretaker
    # multimixins
    unquote_splicing(common.([:controlled, :tagged, :tags, :feed_publishes]))
    # has
    unquote_splicing(common.([:direct_replies]))
  end]

config :bonfire_valueflows, ValueFlows.EconomicResource,
  [code: quote do
    # mixins
    unquote_splicing(common.([:activity, :caretaker, :peered, :replied]))
    # multimixins
    unquote_splicing(common.([:controlled, :tagged, :tags, :feed_publishes]))
    # has
    unquote_splicing(common.([:direct_replies]))
  end]

config :bonfire_valueflows, ValueFlows.Knowledge.ResourceSpecification,
  [code: quote do
    # mixins
    unquote_splicing(common.([:activity, :caretaker, :peered, :replied]))
    # multimixins
    unquote_splicing(common.([:controlled, :tagged, :tags, :feed_publishes]))
    # has
    unquote_splicing(common.([:direct_replies]))
  end]

config :bonfire_valueflows, ValueFlows.Process,
  [code: quote do
    # mixins
    unquote_splicing(common.([:activity, :caretaker, :peered, :replied]))
    # multimixins
    unquote_splicing(common.([:controlled, :tagged, :tags, :feed_publishes]))
    # has
    unquote_splicing(common.([:direct_replies]))
  end]

config :bonfire_valueflows, ValueFlows.Knowledge.ProcessSpecification,
  [code: quote do
    # mixins
    unquote_splicing(common.([:activity, :caretaker, :peered, :replied]))
    # multimixins
    unquote_splicing(common.([:controlled, :tagged, :tags, :feed_publishes]))
    # has
    unquote_splicing(common.([:direct_replies]))
  end]

config :bonfire_valueflows, ValueFlows.Planning.Intent,
  [code: quote do
    # mixins
    unquote_splicing(common.([:activity, :caretaker, :peered, :replied]))
    # multimixins
    unquote_splicing(common.([:controlled, :tagged, :tags, :feed_publishes]))
    # has
    unquote_splicing(common.([:direct_replies]))
  end]

config :bonfire_valueflows, ValueFlows.Planning.Commitment,
  [code: quote do
    # mixins
    unquote_splicing(common.([:activity, :caretaker, :peered, :replied]))
    # multimixins
    unquote_splicing(common.([:controlled, :tagged, :tags, :feed_publishes]))
    # has
    unquote_splicing(common.([:direct_replies]))
  end]

config :bonfire_valueflows, ValueFlows.Proposal,
  [code: quote do
    # mixins
    unquote_splicing(common.([:activity, :caretaker, :peered, :replied]))
    # multimixins
    unquote_splicing(common.([:controlled, :tagged, :tags, :feed_publishes]))
    # has
    unquote_splicing(common.([:direct_replies]))
  end]

config :bonfire_valueflows_observe, ValueFlows.Observe.Observation,
  [code: quote do
    # mixins
    unquote_splicing(common.([:activity, :caretaker, :peered, :replied]))
    # multimixins
    unquote_splicing(common.([:controlled, :tagged, :tags, :feed_publishes]))
    # has
    unquote_splicing(common.([:direct_replies]))
  end]
