import Config

default_flavour = "classic"
flavour = System.get_env("FLAVOUR", default_flavour)
flavour_path = System.get_env("FLAVOUR_PATH", "flavours/" <> flavour)

#### Basic configuration

# You probably won't want to touch these. You might override some in
# other config files.
repo = Bonfire.Common.Repo

config :bonfire,
  otp_app: :bonfire,
  env: config_env(),
  flavour: flavour,
  flavour_path: flavour_path,
  app_name: System.get_env("APP_NAME", "Bonfire"),
  repo_module: repo,
  web_module: Bonfire.UI.Common.Web,
  endpoint_module: Bonfire.Web.Endpoint,
  mailer_module: Bonfire.Mailer,
  default_web_namespace: Bonfire.UI.Common,
  default_layout_module: Bonfire.UI.Common.LayoutView,
  graphql_schema_module: Bonfire.API.GraphQL.Schema,
  user_schema: Bonfire.Data.Identity.User,
  org_schema: Bonfire.Data.Identity.User,
  home_page: Bonfire.Web.HomeLive,
  user_home_page: Bonfire.Web.HomeLive,
  # limit for prod
  default_pagination_limit: 15,
  # very high limit for prod
  thread_default_pagination_limit: 500,
  # how many nested replies to show
  thread_default_max_depth: 3,
  localisation_path: "priv/localisation",
  ap_base_path: System.get_env("AP_BASE_PATH", "/pub"),
  signing_salt: "this-will-be-overriden-by-a-secure-string-in-runtime.exs",
  encryption_salt: "this-will-be-overriden-by-a-secure-string-in-runtime.exs"

config :bonfire, Bonfire.Web.Endpoint,
  url: [host: "localhost"],
  http: [
    # this gets overridden in runtime.exs
    port: String.to_integer(System.get_env("SERVER_PORT", "4000")),
    transport_options: [socket_opts: [:inet6]]
  ],
  render_errors: [view: Bonfire.UI.Common.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Bonfire.PubSub

config :phoenix, :json_library, Jason
config :phoenix_gon, :json_library, Jason

repos = [repo]
config :bonfire, ecto_repos: repos
config :bonfire_umbrella, ecto_repos: repos
config :paginator, ecto_repos: repos
config :activity_pub, ecto_repos: repos
config :ecto_sparkles, :otp_app, :bonfire
config :rauversion_extension, :repo_module, repo
config :activity_pub, :repo, repo
config :activity_pub, :endpoint_module, Bonfire.Web.Endpoint

config :rauversion_extension, :user_schema, Bonfire.Data.Identity.User
config :rauversion_extension, :router_helper, Bonfire.Web.Router.Helpers
config :rauversion_extension, :default_layout_module, Bonfire.UI.Common.LayoutView
config :rauversion_extension, :user_table, "pointers_pointer"
config :rauversion_extension, :user_key_type, :uuid

config :bonfire, Bonfire.Common.Repo, types: Bonfire.Geolocate.PostgresTypes
config :bonfire, Bonfire.Common.TestInstanceRepo, types: Bonfire.Geolocate.PostgresTypes
config :bonfire, Bonfire.Common.TestInstanceRepo, database: "bonfire_test_instance"
# priv: flavour_path <> "/repo"

# ecto query filtering
# config :query_elf, :id_types, [:id, :binary_id, Pointers.ULID]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :elixir, :dbg_callback, {Untangle, :custom_dbg, []}

config :surface, :compiler, warn_on_undefined_props: false

config :bonfire, Oban,
  repo: repo,
  plugins: [Oban.Plugins.Pruner],
  queues: [
    federator_incoming: 50,
    federator_outgoing: 50
  ]

config :mime, :types, %{
  "application/json" => ["json"],
  "application/activity+json" => ["activity+json"],
  "application/ld+json" => ["ld+json"],
  "application/jrd+json" => ["jrd+json"],
  "audio/ogg" => ["ogg"]
}

config :sentry,
  dsn: "this-will-be-overriden-by-a-secure-string-in-runtime.exs",
  environment_name: Mix.env(),
  # enable_source_code_context: true,
  root_source_code_path: File.cwd!(),
  included_environments: [:prod],
  tags: %{app_version: Mix.Project.config()[:version]}

# include Bonfire-specific config files
for config <- "bonfire_*.exs" |> Path.expand(__DIR__) |> Path.wildcard() do
  # IO.inspect(include_config: config)
  import_config config
end

# include configs for the current flavour (augmenting or overriding the previous ones)
for config <- "flavour_*.exs" |> Path.expand(__DIR__) |> Path.wildcard() do
  # IO.inspect(include_config: config)
  import_config config
end

import_config "activity_pub.exs"

# finally, append/override config based on env, which will override any config set above (including from imported files)
import_config "#{config_env()}.exs"
