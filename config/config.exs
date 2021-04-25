import Config

# You will almost certainly want to change at least some of these

# include all used Bonfire extensions
import_config "bonfire_boundaries.exs"
import_config "bonfire_mailer.exs"
import_config "bonfire_federate_activitypub.exs"
import_config "bonfire_files.exs"

import_config "bonfire_me.exs"
import_config "bonfire_social.exs"
import_config "bonfire_tag.exs"

# import_config "bonfire_publisher_thesis.exs"
# import_config "bonfire_fail.exs"
# import_config "bonfire_quantify.exs"
# import_config "bonfire_geolocate.exs"
# import_config "bonfire_valueflows.exs"
# import_config "bonfire_api_graphql.exs"

import_config "bonfire_classify.exs"

import_config "bonfire_search.exs"

# include common modules
import_config "bonfire_common.exs"
import_config "activity_pub.exs"

# include DB schemas
import_config "bonfire_data.exs"

# include hooks (for extensions to hook into each other)
import_config "bonfire_hooks.exs"

# include UI settings
import_config "bonfire_ui.exs"

#### Basic configuration

# You probably won't want to touch these. You might override some in
# other config files.

config :bonfire, :github_token, System.get_env("GITHUB_TOKEN")

signing_salt = System.get_env("SIGNING_SALT", "CqAoopA2")
encryption_salt = System.get_env("ENCRYPTION_SALT", "g7K25as98msad0qlSxhNDwnnzTqklK10")
secret_key_base = System.get_env("SECRET_KEY_BASE", "g7K250qlSxhNDt5qnV6f4HFnyoD7fGUuZ8tbBF69aJCOvUIF8P0U7wnnzTqklK10")

config :bonfire, :signing_salt, signing_salt
config :bonfire, :encryption_salt, encryption_salt

config :bonfire,
  otp_app: :bonfire,
  env: config_env(),
  repo_module: Bonfire.Repo,
  web_module: Bonfire.Web,
  endpoint_module: Bonfire.Web.Endpoint,
  mailer_module: Bonfire.Mailer,
  default_layout_module: Bonfire.Web.LayoutView,
  graphql_schema_module: Bonfire.GraphQL.Schema,
  user_schema: Bonfire.Data.Identity.User,
  org_schema: Bonfire.Data.Identity.User,
  home_page: Bonfire.Web.HomeLive,
  ap_base_path: System.get_env("AP_BASE_PATH", "/pub")

config :bonfire, Bonfire.Web.Endpoint,
  url: [host: "localhost"],
  secret_key_base: secret_key_base,
  render_errors: [view: Bonfire.Web.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Bonfire.PubSub,
  live_view: [signing_salt: signing_salt]

config :phoenix, :json_library, Jason

# config :bonfire, Bonfire.Repo, types: Bonfire.PostgresTypes

config :bonfire,
  ecto_repos: [Bonfire.Repo]

# ecto query filtering
config :query_elf, :id_types, [:id, :binary_id, Pointers.ULID]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]


config :bonfire, Oban,
  repo: Bonfire.Repo,
  plugins: [Oban.Plugins.Pruner],
  queues: [federator_incoming: 50, federator_outgoing: 50]

config :mime, :types, %{
  "application/activity+json" => ["activity+json"]
}

import_config "#{config_env()}.exs"
