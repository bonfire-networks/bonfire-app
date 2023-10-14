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
  # very high limit for prod (so we can load nested threads)
  pagination_hard_max_limit: 500,
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
  pubsub_server: Bonfire.Common.PubSub,
  live_view: [
    # the time of inactivity allowed in the LiveView before compressing its own memory and state. Defaults to 15000ms (15 seconds)
    hibernate_after: String.to_integer(System.get_env("LV_HIBERNATE_AFTER", "7000"))
    # NOTE: see also `LV_TIMEOUT` and `LV_FULLSWEEP_AFTER` for the socket in the endpoint module 
  ]

# FIXME: MDex not defined
config :bonfire, :markdown_library, :earmark

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

# disable Tzdata and replace with Tz library
config :tzdata, :autoupdate, :disabled
config :elixir, :time_zone_database, Tz.TimeZoneDatabase

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

# NOTE: need to declare types to avoid LV uploads failing with `invalid accept filter provided to allow_upload. Expected a file extension with a known MIME type.`
config :mime, :types, %{
  "application/json" => ["json"],
  "application/activity+json" => ["activity+json"],
  "application/ld+json" => ["ld+json"],
  "application/jrd+json" => ["jrd+json"],
  "image/png" => ["png"],
  "image/jpeg" => ["jpg", "jpeg"],
  "image/gif" => ["gif"],
  "image/svg+xml" => ["svg"],
  "image/webp" => ["webp"],
  "image/tiff" => ["tiff"],
  "text/plain" => ["txt"],
  "text/markdown" => ["md"],
  # doc
  "text/csv" => ["csv"],
  "text/tab-separated-values" => ["tsv"],
  "application/pdf" => ["pdf"],
  "application/rtf" => ["rtf"],
  "application/msword" => ["doc", "dot"],
  "application/vnd.openxmlformats-officedocument.wordprocessingml.document" => ["docx"],
  "application/vnd.ms-excel" => ["xls"],
  "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" => ["xlsx"],
  "application/vnd.oasis.opendocument.presentation" => ["odp"],
  "application/vnd.oasis.opendocument.spreadsheet" => ["ods"],
  "application/vnd.oasis.opendocument.text" => ["odt"],
  "application/epub+zip" => ["epub"],
  # archives
  "application/x-tar" => ["tar"],
  "application/x-bzip" => ["bzip"],
  "application/x-bzip2" => ["bzip2"],
  "application/gzip" => ["gz", "gzip"],
  "application/zip" => ["zip"],
  "application/vnd.rar" => ["rar"],
  "application/x-7z-compressed" => ["7z"],
  # audio
  "audio/aac" => ["aac"],
  "audio/mpeg" => ["mpa", "mp2"],
  "audio/mp3" => ["mp3"],
  "audio/ogg" => ["oga"],
  "audio/wav" => ["wav"],
  # "audio/webm"=> ["webm"],
  "audio/opus" => ["opus"],
  "audio/flac" => ["flac"],
  # video
  "video/mp4" => ["mp4"],
  "video/mpeg" => ["mpeg"],
  "video/ogg" => ["ogg", "ogv"],
  "video/webm" => ["webm"]
}

config :os_mon,
  disk_space_check_interval: 60,
  memory_check_interval: 15,
  disk_almost_full_threshold: 0.85,
  start_cpu_sup: false

config :wobserver,
  mode: :plug,
  remote_url_prefix: "/admin/system/wobserver"

config :sentry,
  # dsn: "this-should-be-set-in-env-and-loaded-in-runtime.exs",
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

import_config "native.exs"

# finally, append/override config based on env, which will override any config set above (including from imported files)
import_config "#{config_env()}.exs"
