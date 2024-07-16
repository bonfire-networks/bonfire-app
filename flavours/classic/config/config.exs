import Config

default_flavour = "classic"
flavour = System.get_env("FLAVOUR", default_flavour)
flavour_path = System.get_env("FLAVOUR_PATH", "flavours/" <> flavour)
project_root = File.cwd!()
as_desktop_app? = System.get_env("AS_DESKTOP_APP") in ["1", "true"]
env = config_env()
#### Basic configuration

# You probably won't want to touch these. You might override some in
# other config files.
repo = Bonfire.Common.Repo

cond do
  File.exists?("../extensions/bonfire/config/config.exs") ->
    import_config "../extensions/bonfire/config/config.exs"

  File.exists?("../deps/bonfire/config/config.exs") ->
    import_config "../deps/bonfire/config/config.exs"

  true ->
    import_config "config_basics.exs"
end

config :bonfire,
  otp_app: :bonfire,
  umbrella_otp_app: :bonfire_umbrella,
  env: env,
  project_path: project_root,
  flavour: flavour,
  flavour_path: flavour_path,
  app_name: System.get_env("APP_NAME", "Bonfire"),
  repo_module: repo,
  web_module: Bonfire.UI.Common.Web,
  endpoint_module: if(as_desktop_app?, do: Bonfire.Desktop.Endpoint, else: Bonfire.Web.Endpoint),
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

endpoint_live_view = [
  # the time of inactivity allowed in the LiveView before compressing its own memory and state. Defaults to 15000ms (15 seconds)
  # NOTE: see also `LV_TIMEOUT` and `LV_FULLSWEEP_AFTER` for the socket in the endpoint module
  hibernate_after: String.to_integer(System.get_env("LV_HIBERNATE_AFTER", "7000")),
  signing_salt: System.get_env("SIGNING_SALT")
  # ^ should be overridden at runtime
]

endpoint_render_errors = [
  # view: Bonfire.UI.Common.ErrorView,
  accepts: ~w(html json),
  # layout: false,
  layout: [html: {Bonfire.UI.Common.BasicView, :error}],
  # root_layout: [html: {Bonfire.UI.Common.BasicView, :error}],
  formats: [html: Bonfire.UI.Common.ErrorView, json: Bonfire.UI.Common.ErrorView]
]

config :bonfire, Bonfire.Web.Endpoint,
  url: [host: "localhost"],
  check_origin: :conn,
  http: [
    # this gets overridden in runtime.exs
    port: String.to_integer(System.get_env("SERVER_PORT", "4000"))
  ],
  render_errors: endpoint_render_errors,
  live_view: endpoint_live_view,
  pubsub_server: Bonfire.Common.PubSub

if as_desktop_app? do
  config :bonfire, Bonfire.Desktop.Endpoint,
    server: true,
    url: [host: "localhost"],
    check_origin: :conn,
    http: [
      # so it gets set automatically
      port: 0
    ],
    render_errors: endpoint_render_errors,
    live_view: endpoint_live_view,
    pubsub_server: Bonfire.Common.PubSub,
    secret_key_base: System.get_env("SECRET_KEY_BASE")
end

# Optionally run a 2nd endpoint for testing federation (only used in dev/prod)
config :bonfire, Bonfire.Web.FakeRemoteEndpoint,
  server: true,
  url: [
    host: "localhost",
    port: 4002
  ],
  http: [
    port: 4002
  ],
  render_errors: [view: Bonfire.UI.Common.ErrorView, accepts: ~w(html json), layout: false],
  live_view: endpoint_live_view,
  secret_key_base: System.get_env("SECRET_KEY_BASE")

config :bonfire, :markdown_library, MDEx

config :phoenix, :json_library, Jason
config :phoenix_gon, :json_library, Jason

repos = [repo]
config :bonfire, ecto_repos: repos
config :bonfire_umbrella, ecto_repos: repos
config :paginator, ecto_repos: repos
config :activity_pub, ecto_repos: repos
config :rauversion_extension, :repo_module, repo
config :activity_pub, :repo, repo
config :activity_pub, :endpoint_module, Bonfire.Web.Endpoint
config :paper_trail, repo: repo

config :rauversion_extension, :user_schema, Bonfire.Data.Identity.User
config :rauversion_extension, :router_helper, Bonfire.Web.Router.Helpers
config :rauversion_extension, :default_layout_module, Bonfire.UI.Common.LayoutView
config :rauversion_extension, :user_table, "pointers_pointer"
config :rauversion_extension, :user_key_type, :uuid

config :bonfire_umbrella, Bonfire.Common.Repo, types: Bonfire.Geolocate.PostgresTypes

config :bonfire_umbrella, Bonfire.Common.TestInstanceRepo,
  types: Bonfire.Geolocate.PostgresTypes,
  database: "bonfire_test_instance"

# priv: flavour_path <> "/repo"

# ecto query filtering
# config :query_elf, :id_types, [:id, :binary_id, Needle.ULID]

# disable Tzdata and replace with Tz library
# config :tzdata, :autoupdate, :disabled
# config :elixir, :time_zone_database, Tz.TimeZoneDatabase # FIXME: disabled for now because crashes on Yunohost / Debian 11

config :logger,
  handle_otp_reports: true,
  handle_sasl_reports: true

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :elixir, :dbg_callback, {Untangle, :custom_dbg, []}

config :surface, :compiler, warn_on_undefined_props: false

config :paper_trail,
  item_type: Needle.ULID,
  originator_type: Needle.ULID,
  originator_relationship_options: [references: :id],
  originator: [name: :user, model: Bonfire.Data.Identity.User]

config :nx, default_backend: EXLA.Backend

# NOTE: need to declare types to avoid LV uploads failing with `invalid accept filter provided to allow_upload. Expected a file extension with a known MIME type.`
config :mime, :types, %{
  "application/json" => ["json"],
  "application/activity+json" => ["activity+json"],
  "application/ld+json" => ["ld+json"],
  "application/jrd+json" => ["jrd+json"],
  # images
  "image/png" => ["png"],
  "image/apng" => ["apng"],
  "image/jpeg" => ["jpg", "jpeg"],
  "image/gif" => ["gif"],
  "image/svg+xml" => ["svg"],
  "image/webp" => ["webp"],
  "image/tiff" => ["tiff"],
  # text
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
  "audio/m4a" => ["m4a"],
  "audio/x-m4a" => ["m4a"],
  "audio/mp4" => ["m4a", "mp4"],
  # "audio/webm"=> ["webm"],
  "audio/opus" => ["opus"],
  "audio/flac" => ["flac"],
  # video
  "video/mp4" => ["mp4"],
  "video/mpeg" => ["mpeg"],
  "video/ogg" => ["ogg", "ogv"],
  "video/webm" => ["webm"],
  "video/x-matroska" => ["mkv"],
  "application/x-matroska" => ["mkv"]
}

# define which is preferred when more than one
config :mime, :extensions, %{
  "mkv" => "video/x-matroska",
  "m4a" => "audio/m4a",
  "mp4" => "video/mp4"
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
  # TODO? see https://hexdocs.pm/sentry/upgrade-10-x.html#actively-package-your-source-code
  # NOTE: enabling `enable_source_code_context` errors with `Found two source files in different source root paths with the same relative path`
  enable_source_code_context: false,
  root_source_code_paths:
    [project_root] ++ Bonfire.Mixer.dep_paths(Bonfire.Mixer.deps_names_for(:bonfire)),
  source_code_exclude_patterns: [
    ~r/\/flavours\//,
    ~r/\/extensions\//,
    ~r/\/deps\//,
    ~r/\/_build\//,
    ~r/\/priv\//,
    ~r/\/test\//
  ],
  context_lines: 15,
  tags: %{app_version: Mix.Project.config()[:version]}

if Bonfire.Mixer.compile_disabled?() do
  for dep <-
        Bonfire.Mixer.mess_other_flavour_dep_names(flavour)
        |> Bonfire.Mixer.log(
          "NOTE: these extensions are not part of the #{flavour} flavour and will be available but disabled by default"
        ) do
    config dep,
      modularity: :disabled
  end
end

if System.get_env("WITH_API_GRAPHQL") != "yes" do
  config :bonfire_api_graphql,
    modularity: :disabled
else
  config :bonfire_api_graphql,
    modularity: true
end

# include Bonfire-specific config files
for config <- "bonfire_*.exs" |> Path.expand(__DIR__) |> Path.wildcard() do
  # System.get_env("MIX_QUIET") || IO.inspect(include_config: config)
  import_config config
end

# include configs for the current flavour (augmenting or overriding the previous ones)
flavour_config = "flavour_#{flavour}.exs" |> Path.expand(__DIR__)

if File.exists?(flavour_config) do
  System.get_env("MIX_QUIET") ||
    IO.puts("Include flavour-specific config from `#{flavour_config}`")

  import_config("flavour_#{flavour}.exs")
else
  System.get_env("MIX_QUIET") ||
    IO.puts("You could put any flavour-specific config at `#{flavour_config}`")
end

# federation library
import_config "activity_pub.exs"

# native app
import_config "native.exs"

# finally, append/override config based on env, which will override any config set above (including from imported files)
import_config "#{env}.exs"
