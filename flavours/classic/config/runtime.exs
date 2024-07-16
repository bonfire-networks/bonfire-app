# In this file, we load production configuration and secrets
# from environment variables. You can also hardcode secrets,
# although such is generally not recommended and you have to
# remember to add this file to your .gitignore.
import Config

System.get_env("MIX_QUIET") || IO.puts("🔥 Welcome to Bonfire!")

flavour = System.get_env("FLAVOUR", "classic")
host = System.get_env("HOSTNAME", "localhost")
server_port = String.to_integer(System.get_env("SERVER_PORT", "4000"))
public_port = String.to_integer(System.get_env("PUBLIC_PORT", "4000"))
test_instance = System.get_env("TEST_INSTANCE")

yes? = ~w(true yes 1)
no? = ~w(false no 0)

repos =
  if Code.ensure_loaded?(Beacon.Repo),
    do: [Bonfire.Common.Repo, Beacon.Repo],
    else: [Bonfire.Common.Repo]

repos =
  if test_instance in yes?,
    do: repos ++ [Bonfire.Common.TestInstanceRepo],
    else: repos

hosts =
  "#{host}#{System.get_env("EXTRA_DOMAINS")}"
  |> String.replace(["`", " "], "")
  |> String.split(",")
  |> Enum.map(&"//#{&1}")

# |> IO.inspect()

## load extensions' runtime configs (and behaviours) directly via extension-provided modules
Bonfire.Common.Config.LoadExtensionsConfig.load_configs(Bonfire.RuntimeConfig)
##

System.get_env("DATABASE_URL") || System.get_env("POSTGRES_PASSWORD") ||
  System.get_env("MIX_QUIET") || System.get_env("CI") ||
  raise """
  Environment variables for database are missing.
  For example: DATABASE_URL=ecto://USER:PASS@HOST/DATABASE
  You can also set POSTGRES_PASSWORD (required),
  and POSTGRES_USER (default: postgres) and POSTGRES_HOST (default: localhost)
  """

maybe_repo_ipv6 = if System.get_env("ECTO_IPV6") in yes?, do: [:inet6], else: []

repo_connection_config =
  if System.get_env("DATABASE_URL") do
    [
      url: System.get_env("DATABASE_URL"),
      socket_options: maybe_repo_ipv6
    ]
  else
    [
      username: System.get_env("POSTGRES_USER", "postgres"),
      password: System.get_env("POSTGRES_PASSWORD", "postgres"),
      hostname: System.get_env("POSTGRES_HOST", "localhost"),
      socket_options: maybe_repo_ipv6
    ]
  end

secret_key_base =
  System.get_env("SECRET_KEY_BASE") || System.get_env("MIX_QUIET") || System.get_env("CI") ||
    raise """
    environment variable SECRET_KEY_BASE is missing.
    You can generate one by calling: mix phx.gen.secret
    """

signing_salt =
  System.get_env("SIGNING_SALT") || System.get_env("MIX_QUIET") || System.get_env("CI") ||
    raise """
    environment variable SIGNING_SALT is missing.
    """

encryption_salt =
  System.get_env("ENCRYPTION_SALT") || System.get_env("MIX_QUIET") || System.get_env("CI") ||
    raise """
    environment variable ENCRYPTION_SALT is missing.
    """

cute_gifs_dir = System.get_env("CUTE_GIFS_DIR", "data/uploads/cute-gifs/")

config :bonfire,
  # how many nested replies to show
  thread_default_max_depth: 7,
  feed_live_update_many_preloads: :async_actions,
  host: host,
  default_cache_hours: String.to_integer(System.get_env("BONFIRE_CACHE_HOURS", "3")),
  app_name: System.get_env("APP_NAME", "Bonfire"),
  ap_base_path: System.get_env("AP_BASE_PATH", "/pub"),
  # github_app_client_id: System.get_env("GITHUB_APP_CLIENT_ID", "Iv1.8d612e6e5a2149c9"),
  github_token: System.get_env("GITHUB_TOKEN"),
  show_debug_errors_in_dev: System.get_env("SHOW_DEBUG_IN_DEV"),
  encryption_salt: encryption_salt,
  signing_salt: signing_salt,
  root_path: File.cwd!(),
  cute_gifs: [
    num: length(Path.wildcard(cute_gifs_dir <> "*.gif")),
    dir: cute_gifs_dir
  ]

phx_server = System.get_env("PHX_SERVER")
use_cowboy? = System.get_env("PLUG_SERVER") != "bandit"

config :bonfire, Bonfire.Web.Endpoint,
  server:
    phx_server not in no? and
      (config_env() != :test or test_instance in yes? or phx_server in yes?),
  url: [
    host: host,
    port: public_port
  ],
  # check_origin: hosts, # FIXME
  check_origin: false,
  adapter:
    if(use_cowboy?,
      do: Phoenix.Endpoint.Cowboy2Adapter,
      else: Bandit.PhoenixAdapter
    ),
  http:
    if(use_cowboy?,
      do: [
        port: server_port,
        # only bind the app to localhost when serving behind a proxy
        # ip: (if public_port != server_port, do: {127, 0, 0, 1}),
        transport_options: [max_connections: 16_384, socket_opts: [:inet6]]
      ],
      # for bandit
      else: [
        port: server_port
      ]
    ),
  thousand_island: [transport_ports: [hibernate_after: 15_000]],
  secret_key_base: secret_key_base,
  live_view: [signing_salt: signing_salt]

case System.get_env("SENTRY_DSN", "") do
  "" ->
    config :sentry, modularity: :disabled

  dsn ->
    IO.puts("NOTE: errors will be reported to Sentry.")

    config :sentry,
      dsn: dsn,
      integrations: [
        oban: [
          capture_errors: true,
          cron: [enabled: true]
        ]
      ]

    if System.get_env("SENTRY_NAME") do
      config :sentry, server_name: System.get_env("SENTRY_NAME")
    end
end

pool_size =
  case System.get_env("POOL_SIZE") do
    pool when is_binary(pool) and pool not in ["", "0"] ->
      String.to_integer(pool)

    # default to twice the number of CPU cores
    _ ->
      System.schedulers_online() * 2
  end

IO.puts("Note: Starting database connection pool of #{pool_size}")

database =
  case config_env() do
    :test ->
      "bonfire_test_#{test_instance}_#{System.get_env("MIX_TEST_PARTITION")}"

    :dev ->
      System.get_env("POSTGRES_DB", "bonfire_dev")

    _ ->
      System.get_env("POSTGRES_DB", "bonfire")
  end

config :bonfire, ecto_repos: repos
config :bonfire_umbrella, ecto_repos: repos
config :paginator, ecto_repos: repos
config :activity_pub, ecto_repos: repos

config :bonfire_umbrella, Bonfire.Common.Repo, repo_connection_config
config :bonfire_umbrella, Bonfire.Common.TestInstanceRepo, repo_connection_config
config :beacon, Beacon.Repo, repo_connection_config

config :bonfire_umbrella, Bonfire.Common.Repo, database: database
config :beacon, Beacon.Repo, database: database
config :paginator, Paginator.Repo, database: database

config :bonfire_umbrella, Bonfire.Common.Repo, pool_size: pool_size
config :bonfire_umbrella, Bonfire.Common.TestInstanceRepo, pool_size: pool_size
config :beacon, Beacon.Repo, pool_size: pool_size
config :paginator, Paginator.Repo, pool_size: pool_size

repo_path = System.get_env("DB_REPO_PATH", "priv/repo")
config :bonfire_umbrella, Bonfire.Common.Repo, priv: repo_path
config :bonfire_umbrella, Bonfire.Common.TestInstanceRepo, priv: repo_path

config :bonfire, Oban,
  repo: Bonfire.Common.Repo,
  # avoid extra PubSub chatter as we don't need that much precision
  insert_trigger: false,
  # time between making scheduled jobs available and notifying relevant queues that jobs are available, affects how frequently the database is checked for jobs to run
  stage_interval: :timer.seconds(2),
  queues: [
    federator_incoming: 2,
    federator_outgoing: 2,
    remote_fetcher: 1,
    import: 1,
    deletion: 1,
    database_prune: 1,
    static_generator: 1,
    # video_transcode: 1,
    fetch_open_science: 1
  ],
  plugins: [
    #  delete job history after 7 days
    {Oban.Plugins.Pruner, max_age: 60 * 60 * 24 * 7},
    # rescue orphaned jobs
    {Oban.Plugins.Lifeline, rescue_after: :timer.minutes(60)},
    {Oban.Plugins.Cron,
     crontab:
       [
         #  generate static pages for guests every 10 min
         {"*/10 * * * *", Bonfire.UI.Common.StaticGenerator, max_attempts: 3},
         {"@daily", ActivityPub.Pruner.PruneDatabaseWorker, max_attempts: 1}
       ] ++
         if Bonfire.Common.Extend.extension_enabled?(:bonfire_open_science) do
           IO.puts(
             "Open science publications will be fetched for all users at regular intervals."
           )

           [{"@hourly", Bonfire.OpenScience.APIs}]
         else
           IO.puts("Open science extension is not enabled")
           []
         end}
  ]

config :activity_pub, :oban_queues,
  retries: [federator_incoming: 2, federator_outgoing: 3, remote_fetcher: 1]

config :activity_pub, Oban,
  # to avoid running it twice
  queues: false,
  repo: Bonfire.Common.Repo

config :activity_pub, ActivityPub.Federator.HTTP.RateLimit,
  scale_ms: String.to_integer(System.get_env("AP_RATELIMIT_PER_MS", "10000")),
  limit: String.to_integer(System.get_env("AP_RATELIMIT_NUM", "20"))

case System.get_env("GRAPH_DB_URL") do
  nil ->
    nil

  url ->
    config :bolt_sips, Bolt,
      url: url,
      basic_auth: [username: "memgraph", password: "memgraph"],
      pool_size: pool_size
end

if (config_env() == :prod or System.get_env("OTEL_ENABLED") in yes?) and
     (System.get_env("OTEL_EXPORTER_OTLP_ENDPOINT") || System.get_env("OTEL_LIGHTSTEP_API_KEY") ||
        System.get_env("OTEL_HONEYCOMB_API_KEY")) do
  config :opentelemetry_exporter,
    otlp_protocol: :http_protobuf

  otel_endpoint = System.get_env("OTEL_EXPORTER_OTLP_ENDPOINT")

  if otel_endpoint do
    IO.puts("NOTE: OTLP (open telemetry) data will be sent to #{otel_endpoint}")

    config :opentelemetry_exporter,
      otlp_endpoint: otel_endpoint
  end

  if System.get_env("OTEL_LIGHTSTEP_API_KEY") do
    IO.puts("NOTE: OTLP (open telemetry) data will be sent to lightstep / servicenow.com")

    # Example configuration, for more refer to: https://github.com/open-telemetry/opentelemetry-erlang/tree/main/apps/opentelemetry_exporter#application-environment
    config :opentelemetry_exporter,
      # You can configure the compression type for exporting traces.
      otlp_compression: :gzip,
      oltp_traces_compression: :gzip,
      otlp_traces_endpoint: "https://ingest.lightstep.com:443/traces/otlp/v0.9",
      otlp_headers: [
        {"lightstep-access-token", System.get_env("OTEL_LIGHTSTEP_API_KEY")}
      ]
  end

  if System.get_env("OTEL_HONEYCOMB_API_KEY") do
    IO.puts("NOTE: OTLP (open telemetry) data will be sent to honeycomb.io")

    config :opentelemetry, :processors,
      otel_batch_processor: %{
        exporter: {
          :opentelemetry_exporter,
          %{
            endpoints: [
              {:https, ~c"api.honeycomb.io", 443,
               [
                 verify: :verify_peer,
                 cacertfile: :certifi.cacertfile(),
                 depth: 3,
                 customize_hostname_check: [
                   match_fun: :public_key.pkix_verify_hostname_match_fun(:https)
                 ]
               ]}
            ],
            headers: [
              {"x-honeycomb-team", System.fetch_env!("OTEL_HONEYCOMB_API_KEY")},
              {"x-honeycomb-dataset", System.get_env("OTEL_SERVICE_NAME", "bonfire")}
            ],
            protocol: :grpc
          }
        }
      }
  end
else
  config :opentelemetry,
    modularity: :disabled
end

config :ecto_sparkles,
  slow_query_ms: String.to_integer(System.get_env("DB_SLOW_QUERY_MS", "100")),
  queries_log_level: String.to_atom(System.get_env("DB_QUERIES_LOG_LEVEL", "debug"))

# start prod-only config
if config_env() == :prod do
  config :bonfire_umbrella, Bonfire.Common.Repo,
    # ssl: true,
    # database: System.get_env("POSTGRES_DB", "bonfire"),
    # Note: keep this disabled if using ecto_dev_logger or EctoSparkles.Log instead #
    log: String.to_atom(System.get_env("DB_QUERIES_LOG_LEVEL", "false"))
end

# end prod only config

# start prod and dev only config
if config_env() != :test do
  config :bonfire_umbrella, Bonfire.Common.Repo,
    # The timeout for establishing new connections (default: 5000)
    connect_timeout: String.to_integer(System.get_env("DB_CONNECT_TIMEOUT", "10000")),
    # The time in milliseconds (as an integer) to wait for the query call to finish (default: 15_000)
    timeout: String.to_integer(System.get_env("DB_QUERY_TIMEOUT", "20000")),
    parameters: [
      # Abort any statement that takes more than the specified amount of time. The timeout is measured from the time a command arrives at the server until it is completed by the server.
      statement_timeout: System.get_env("DB_STATEMENT_TIMEOUT", "20000"),
      # idle-in-transaction timeout: terminates any session with an open transaction that has been idle for longer than the specified amount of time. This allows any locks held by that session to be released and the connection slot to be reused. WARNING: this seems to also apply to migrations when running in a release, so needs to be high enough for DB migrations and fixtures to run. 
      idle_in_transaction_session_timeout: System.get_env("DB_IDLE_TRANSACTION_TIMEOUT", "5000")
    ]
end

## bonfire_livebook
if Code.ensure_loaded?(Livebook) do
  Livebook.config_runtime()
end

config :forecastr,
  backend: Forecastr.PirateWeather,
  appid: System.get_env("PIRATE_WEATHER_API"),
  # backend: Forecastr.OWM,
  # appid: System.get_env("OPEN_WEATHER_MAP_API_KEY"),
  # minutes to cache
  ttl: 14 * 60_000
