import Config

default_flavour = "classic"
flavour = System.get_env("FLAVOUR", default_flavour)
flavour_path = System.get_env("FLAVOUR_PATH", "flavours/"<>flavour)

#### Basic configuration

# You probably won't want to touch these. You might override some in
# other config files.

config :bonfire,
  otp_app: :bonfire,
  env: config_env(),
  flavour: flavour,
  flavour_path: flavour_path,
  app_name: System.get_env("APP_NAME", "Bonfire"),
  repo_module: Bonfire.Repo,
  web_module: Bonfire.Web,
  endpoint_module: Bonfire.Web.Endpoint,
  mailer_module: Bonfire.Mailer,
  default_web_namespace: Bonfire.UI.Social.Web,
  default_layout_module: Bonfire.UI.Social.Web.LayoutView,
  graphql_schema_module: Bonfire.GraphQL.Schema,
  user_schema: Bonfire.Data.Identity.User,
  org_schema: Bonfire.Data.Identity.User,
  home_page: Bonfire.Web.HomeLive,
  default_pagination_limit: 40, # high limit for prod
  thread_default_pagination_limit: 500, # very high limit for prod
  thread_default_max_depth: 3, # how many nested replies to show
  localisation_path: "priv/localisation",
  ap_base_path: System.get_env("AP_BASE_PATH", "/pub"),
  signing_salt: "this-will-be-overriden-by-a-secure-string-in-runtime.exs",
  encryption_salt: "this-will-be-overriden-by-a-secure-string-in-runtime.exs"

config :bonfire, Bonfire.Web.Endpoint,
  url: [host: "localhost"],
  http: [
    port: String.to_integer(System.get_env("SERVER_PORT", "4000")), # this gets overriden in runtime.exs
    transport_options: [socket_opts: [:inet6]]
  ],
  render_errors: [view: Bonfire.UI.Social.Web.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Bonfire.PubSub

config :phoenix, :json_library, Jason
config :phoenix_gon, :json_library, Jason

config :bonfire, :ecto_repos, [Bonfire.Repo]
config :bonfire, Bonfire.Repo,
  types: Bonfire.PostgresTypes,
  priv: flavour_path <> "/repo"
config :ecto_sparkles, :otp_app, :bonfire

# ecto query filtering
# config :query_elf, :id_types, [:id, :binary_id, Pointers.ULID]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :bonfire, Oban,
  repo: Bonfire.Repo,
  plugins: [Oban.Plugins.Pruner],
  queues: [
    federator_incoming: 50,
    federator_outgoing: 50,
    ap_incoming: 15,
    ap_publish: 15
  ]

  "application/activity+json" => ["activity+json"],
  "application/ld+json" => ["ld+json"],
  "application/jrd+json" => ["jrd+json"]
}


config :sentry,
  dsn: "this-will-be-overriden-by-a-secure-string-in-runtime.exs",
  environment_name: Mix.env,
  included_environments: [:prod]


# include config for all used Bonfire extensions
for config <- "bonfire_*.exs" |> Path.expand(__DIR__) |> Path.wildcard() do
  # IO.inspect(include_config: config)
  import_config config
end

import_config "activity_pub.exs"


# finally, append/override config based on env, which will override any config set above (including from imported files)
import_config "#{config_env()}.exs"
