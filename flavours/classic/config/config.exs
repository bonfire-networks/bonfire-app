import Config

default_flavour = "classic"
flavour = System.get_env("FLAVOUR", default_flavour)
flavour_path = System.get_env("FLAVOUR_PATH", "flavours/" <> flavour)
project_root = File.cwd!()
#### Basic configuration

# You probably won't want to touch these. You might override some in
# other config files.
repo = Bonfire.Common.Repo

config :bonfire,
  otp_app: :bonfire,
  umbrella_otp_app: :bonfire_umbrella,
  env: config_env(),
  project_path: project_root,
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
  home_page: :home,
  user_home_page: :dashboard,
  # default limit for prod
  default_pagination_limit: 20,
  # very high limit for prod
  thread_default_pagination_limit: 500,
  localisation_path: "priv/localisation",
  ap_base_path: System.get_env("AP_BASE_PATH", "/pub"),
  signing_salt: "this-will-be-overriden-by-a-secure-string-in-runtime.exs",
  encryption_salt: "this-will-be-overriden-by-a-secure-string-in-runtime.exs"

config :bonfire, Bonfire.Web.Endpoint,
  url: [host: "localhost"],
  check_origin: :conn,
  http: [
    # this gets overridden in runtime.exs
    port: String.to_integer(System.get_env("SERVER_PORT", "4000"))
  ],
  render_errors: [
    # view: Bonfire.UI.Common.ErrorView, 
    accepts: ~w(html json),
    # layout: false,
    layout: [html: {Bonfire.UI.Common.BasicView, :error}],
    # root_layout: [html: {Bonfire.UI.Common.BasicView, :error}],
    formats: [html: Bonfire.UI.Common.ErrorView, json: Bonfire.UI.Common.ErrorView]
  ],
  pubsub_server: Bonfire.Common.PubSub

config :phoenix, :json_library, Jason
config :phoenix_gon, :json_library, Jason

repos = [repo]
config :bonfire, ecto_repos: repos
config :bonfire_umbrella, ecto_repos: repos
config :paginator, ecto_repos: repos
config :activity_pub, ecto_repos: repos
config :ecto_sparkles, :otp_app, :bonfire
config :ecto_sparkles, :umbrella_otp_app, :bonfire_umbrella
config :rauversion_extension, :repo_module, repo
config :activity_pub, :repo, repo
config :activity_pub, :endpoint_module, Bonfire.Web.Endpoint
config :paper_trail, repo: repo

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
    federator_incoming: 10,
    federator_outgoing: 10,
    remote_fetcher: 5,
    import: 2,
    deletion: 1
  ]

config :paper_trail,
  item_type: Pointers.ULID,
  originator_type: Pointers.ULID,
  originator_relationship_options: [references: :id],
  originator: [name: :user, model: Bonfire.Data.Identity.User]

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
  root_source_code_path: project_root,
  included_environments: [:prod],
  tags: %{app_version: Mix.Project.config()[:version]}

# include Bonfire-specific config files
for config <- "bonfire_*.exs" |> Path.expand(__DIR__) |> Path.wildcard() do
  # IO.inspect(include_config: config)
  import_config config
end

# include configs for the current flavour (augmenting or overriding the previous ones)
flavour_config = "flavour_#{flavour}.exs" |> Path.expand(__DIR__)

if File.exists?(flavour_config) do
  IO.puts("Include flavour-specific config from `#{flavour_config}`")
  import_config("flavour_#{flavour}.exs")
else
  IO.puts("You could put any flavour-specific config at `#{flavour_config}`")
end

import_config "activity_pub.exs"

# finally, append/override config based on env, which will override any config set above (including from imported files)
import_config "#{config_env()}.exs"
