use Mix.Config

config :pointers,
  search_path: [
    :cpub_accounts,
    :cpub_communities,
    :cpub_emails,
    :cpub_local_auth,
    :cpub_profiles,
    :cpub_users,
    :vox_publica,
  ]

alias CommonsPub.Accounts.Account
alias CommonsPub.Emails.Email
alias CommonsPub.LocalAuth.LoginCredential
alias CommonsPub.Profiles.Profile
alias CommonsPub.Users.User

config :cpub_accounts, Account,
  has_one: [email:            {Email,           foreign_key: :id}],
  has_one: [login_credential: {LoginCredential, foreign_key: :id}]

config :cpub_local_auth, LoginCredential,
  belongs_to: [account: {Account, foreign_key: :id, define_field: false}],
  rename_attrs: [email: :identity],
  password: [length: [min: 8, max: 64]]

config :cpub_profiles, Profile,
  belongs_to: [user: {User, foreign_key: :id, define_field: false}]

config :cpub_users, User,
  has_one: [profile: {Profile, foreign_key: :id}]

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

import_config "#{Mix.env()}.exs"
