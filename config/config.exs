import Config

#### Email configuration

# You will almost certainly want to change at least some of these

alias Bonfire.Mailer

config :bonfire, Mailer,
  from_address: "noreply@bonfire.local"

# include DB schemas
import_config "bonfire_data.exs"

# include all used Bonfire extensions
import_config "bonfire_me.exs"
# import_config "bonfire_publisher_thesis.exs"


#### Basic configuration

# You probably won't want to touch these. You might override some in
# other config files.

signing_salt = System.get_env("SIGNING_SALT", "CqAoopA2")
encryption_salt = System.get_env("ENCRYPTION_SALT", "g7K25as98msad0qlSxhNDwnnzTqklK10")
secret_key_base = System.get_env("SECRET_KEY_BASE", "g7K250qlSxhNDt5qnV6f4HFnyoD7fGUuZ8tbBF69aJCOvUIF8P0U7wnnzTqklK10")

config :bonfire, :signing_salt, signing_salt
config :bonfire, :encryption_salt, encryption_salt
config :bonfire, :routes_module, Bonfire.Web.Routes
config :bonfire, :routes_helper_module, Bonfire.Web.Routes.Helpers
config :bonfire, :live_view_module, Bonfire.Web.PageLive
config :bonfire, :otp_app, :bonfire

config :bonfire, Bonfire.Web.Endpoint,
  url: [host: "localhost"],
  secret_key_base: secret_key_base,
  render_errors: [view: Bonfire.Web.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Bonfire.PubSub,
  live_view: [signing_salt: signing_salt]

config :phoenix, :json_library, Jason

config :bonfire,
  ecto_repos: [Bonfire.Repo]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :activity_pub, :adapter, Bonfire.ActivityPub.Adapter
config :activity_pub, :repo, Bonfire.Repo

config :bonfire, Oban,
  repo: Bonfire.Repo,
  plugins: [Oban.Plugins.Pruner],
  queues: [federator_incoming: 50, federator_outgoing: 50]

config :mime, :types, %{
  "application/activity+json" => ["activity+json"]
}

import_config "#{config_env()}.exs"
