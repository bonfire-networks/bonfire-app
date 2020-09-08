use Mix.Config

config :pointers,
  search_path: [
    :cpub_activities,
    :cpub_accounts,
    :cpub_blocks,
    :cpub_bookmarks,
    :cpub_characters,
    :cpub_comments,
    :cpub_communities,
    :cpub_circles,
    :cpub_emails,
    :cpub_features,
    :cpub_follows,
    :cpub_likes,
    :cpub_local_auth,
    :cpub_profiles,
    :cpub_threads,
    :cpub_users,
    :vox_publica,
  ]

alias CommonsPub.Accounts.{Account, Accounted}
alias CommonsPub.{
  Blocks.Block,
  Characters.Character,
  Comments.Comment,
  Communities.Communities,
  Circles.Circle,
  Emails.Email,
  Features.Feature,
  Follows.Follow,
  Likes.Like,
  LocalAuth.LoginCredential,
  Profiles.Profile,
  Threads.Thread,
  Users.User,
} 

config :cpub_accounts, Account,
  has_one: [email:            {Email,           foreign_key: :id}],
  has_one: [login_credential: {LoginCredential, foreign_key: :id}],
  has_many: [accounted: Accounted],
  has_many: [users:     [through: [:accounted, :user]]]

config :cpub_accounts, Accounted,
  belongs_to: [user: {User, foreign_key: :id, define_field: false}]

config :cpub_characters, Character,
  belongs_to: [user: {User, foreign_key: :id, define_field: false}]
  
config :cpub_emails, Email,
  belongs_to: [account: {Account, foreign_key: :id, define_field: false}]

config :cpub_local_auth, LoginCredential,
  belongs_to: [account: {Account, foreign_key: :id, define_field: false}],
  rename_attrs: [email: :identity],
  password: [length: [min: 8, max: 64]]

config :cpub_profiles, Profile,
  belongs_to: [user: {User, foreign_key: :id, define_field: false}]

config :cpub_users, User,
  has_one: [accounted: {Accounted, foreign_key: :id}],
  has_one: [character: {Character, foreign_key: :id}],
  has_one: [profile:   {Profile,   foreign_key: :id}]

config :vox_publica,
  ecto_repos: [VoxPublica.Repo]

# Configures the endpoint
config :vox_publica, VoxPublica.Web.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "g7K250qlSxhNDt5qnV6f4HFnyoD7fGUuZ8tbBF69aJCOvUIF8P0U7wnnzTqklK10",
  render_errors: [view: VoxPublica.Web.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: VoxPublica.PubSub,
  live_view: [signing_salt: "9vdUm+Kh"]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

config :activity_pub, :adapter, VoxPublica.ActivityPub.Adapter
config :activity_pub, :repo, VoxPublica.Repo

config :vox_publica, Oban,
  repo: VoxPublica.Repo,
  plugins: [Oban.Plugins.Pruner],
  queues: [federator_incoming: 50, federator_outgoing: 50]

import_config "#{Mix.env()}.exs"
