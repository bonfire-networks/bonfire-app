# In this file, we load production configuration and secrets
# from environment variables. You can also hardcode secrets,
# although such is generally not recommended and you have to
# remember to add this file to your .gitignore.
import Config

IO.puts("Preparing runtime config...")

System.get_env("MIX_QUIET") || IO.puts("🔥 Welcome to Bonfire!")

yes? = ~w(true yes 1)
no? = ~w(false no 0)

# flavour = System.get_env("FLAVOUR", "classic")
host = System.get_env("HOSTNAME", "localhost")
server_port = String.to_integer(System.get_env("SERVER_PORT", "4000"))
public_port = String.to_integer(System.get_env("PUBLIC_PORT", "4000"))
test_instance? = System.get_env("TEST_INSTANCE") in yes?
federate? = test_instance? or System.get_env("FEDERATE") in yes?

# hosts =
#   "#{host}#{System.get_env("EXTRA_DOMAINS")}"
#   |> String.replace(["`", " "], "")
#   |> String.split(",")
#   |> Enum.map(&"//#{&1}")

System.get_env("DATABASE_URL") || System.get_env("CLOUDRON_POSTGRESQL_URL") ||
  System.get_env("POSTGRES_PASSWORD") || System.get_env("CLOUDRON_POSTGRESQL_PASSWORD") ||
  System.get_env("MIX_QUIET") || System.get_env("CI") ||
  raise """
  Environment variables for database are missing.
  For example: DATABASE_URL=ecto://USER:PASS@HOST/DATABASE
  You can also set POSTGRES_PASSWORD (required),
  and POSTGRES_USER (default: postgres) and POSTGRES_HOST (default: localhost)
  """

## load extensions' runtime configs (and behaviours) directly via extension-provided modules
Bonfire.Common.Config.LoadExtensionsConfig.load_configs([Bonfire.RuntimeConfig])
##

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
  thread_default_max_depth: String.to_integer(System.get_env("THREAD_DEPTH", "3")),
  feed_live_update_many_preload_mode: :async_actions,
  host: host,
  pot_url_prefix: System.get_env("BONFIRE_POT_URL_PREFIX"),
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

if System.get_env("ENABLE_STATIC_CACHING") not in yes? do
  config :bonfire_ui_common, Bonfire.UI.Common.StaticGenerator, modularity: :disabled
end

phx_server = System.get_env("PHX_SERVER")
plug_server = System.get_env("PLUG_SERVER")
use_cowboy? = plug_server == "cowboy"
use_socket_file? = plug_server == "cowboy_socket"
socket_file_path = System.get_env("SOCKET_FILE_PATH", "/tmp/bonfire_socket")
phx_compress? = System.get_env("PHX_COMPRESS_HTTP") not in no?

if System.get_env("DISABLE_LOG") in yes? do
  # to suppress non-captured logs in tests (eg. in setup_all)
  config :logger, backends: []
end

http_options =
  cond do
    use_socket_file? ->
      [
        ip: {:local, socket_file_path},
        port: 0,
        compress: phx_compress?,
        transport_options: [
          post_listen_callback: fn _ ->
            File.touch!(socket_file_path)
            File.chmod!(socket_file_path, 0o660)
          end,
          socket_opts: []
        ]
      ]

    use_cowboy? ->
      [
        # only bind the app to localhost when serving behind a proxy
        # ip: (if public_port != server_port, do: {127, 0, 0, 1}),
        port: server_port,
        compress: phx_compress?,
        transport_options: [
          max_connections: 16_384,
          socket_opts: [:inet6]
        ]
      ]

    true ->
      # for bandit
      [
        port: server_port,
        http_options: [
          compress: phx_compress?
        ]
      ]
  end

config :bonfire, Bonfire.Web.Endpoint,
  server:
    phx_server not in no? and
      (config_env() != :test or test_instance? or phx_server in yes?),
  url: [
    host: host,
    port: public_port
  ],
  # check_origin: hosts, # FIXME?
  check_origin: false,
  adapter:
    if(use_cowboy?,
      do: Phoenix.Endpoint.Cowboy2Adapter,
      else: Bandit.PhoenixAdapter
    ),
  http: http_options,
  thousand_island: [transport_ports: [hibernate_after: to_timeout(second: 15)]],
  secret_key_base: secret_key_base,
  live_view: [signing_salt: signing_salt]

if test_instance? do
  test_instance_hostname = System.get_env("TEST_INSTANCE_HOSTNAME", "localhost")

  test_instance_server_port =
    String.to_integer(System.get_env("TEST_INSTANCE_SERVER_PORT", "4002"))

  config :bonfire, Bonfire.Web.FakeRemoteEndpoint,
    url: [
      host: test_instance_hostname,
      port:
        if(test_instance_hostname != "localhost",
          do: public_port,
          else: test_instance_server_port
        )
    ],
    http: [
      port: test_instance_server_port
    ],
    secret_key_base: secret_key_base
end

# HTTP client(s) configuration

finch_conn_opts = [case_sensitive_headers: true]

finch_conn_opts =
  finch_conn_opts ++
    case System.get_env("HTTP_PROXY_URL") do
      nil ->
        []

      uri ->
        uri =
          uri
          |> URI.parse()

        [proxy: {String.to_existing_atom(uri.scheme), uri.host, uri.port, []}]
    end

finch_pools = %{
  :default => [
    # Number of connections to maintain in each pool (HTTP1)
    size: String.to_integer(System.get_env("FINCH_POOL_SIZE", "50")),
    # Number of pools to start (increasing is only useful for HTTP2, which we don't use by default)
    count: String.to_integer(System.get_env("FINCH_POOL_COUNT", "1")),
    # 10 min by default
    pool_max_idle_time: String.to_integer(System.get_env("FINCH_POOL_MAX_IDLE_TIME", "600000")),
    conn_opts: finch_conn_opts
  ],
  "https://icons.duckduckgo.com" => [
    conn_opts: [transport_opts: [size: 8, timeout: to_timeout(second: 3), conn_opts: finch_conn_opts]]
  ],
  "https://www.google.com/s2/favicons" => [
    conn_opts: [transport_opts: [size: 8, timeout: to_timeout(second: 3), conn_opts: finch_conn_opts]]
  ]
}

# config :tesla, adapter: Tesla.Adapter.Hackney
config :bonfire, :finch_pools, finch_pools

if config_env() != :test or federate? do
  config :tesla, :adapter, {Tesla.Adapter.Finch, name: Bonfire.Finch, pools: finch_pools}
end

config :bonfire, Oban,
  notifier: Oban.Notifiers.PG,
  repo: Bonfire.Common.Repo,
  # avoid extra PubSub chatter as we don't need that much precision
  insert_trigger: false,
  # time between making scheduled jobs available and notifying relevant queues that jobs are available, affects how frequently the database is checked for jobs to run
  stage_interval: :timer.seconds(2),
  queues: [
    federator_incoming_mentions:
      String.to_integer(System.get_env("QUEUE_SIZE_AP_IN_MENTIONS", "3")),
    federator_incoming_follows:
      String.to_integer(System.get_env("QUEUE_SIZE_AP_IN_FOLLOWS", "2")),
    federator_incoming: String.to_integer(System.get_env("QUEUE_SIZE_AP_IN", "3")),
    federator_incoming_unverified:
      String.to_integer(System.get_env("QUEUE_SIZE_AP_IN_UNVERIFIED", "1")),
    federator_outgoing: String.to_integer(System.get_env("QUEUE_SIZE_AP_OUT", "3")),
    remote_fetcher: String.to_integer(System.get_env("QUEUE_SIZE_AP_FETCH", "1")),
    import: String.to_integer(System.get_env("QUEUE_SIZE_IMPORT", "1")),
    deletion: String.to_integer(System.get_env("QUEUE_SIZE_DELETION", "1")),
    database_prune: String.to_integer(System.get_env("QUEUE_SIZE_DB_PRUNE", "1")),
    static_generator: String.to_integer(System.get_env("QUEUE_SIZE_STATIC_GEN", "1")),
    # video_transcode: 1,
    # boost_activities: 1,
    fetch_open_science: String.to_integer(System.get_env("QUEUE_SIZE_OPEN_SCIENCE_FETCH", "1"))
  ],
  plugins: [
    # delete job history after 6 hours
    {Oban.Plugins.Pruner, max_age: 60 * 60 * 6},
    # rescue orphaned jobs
    {Oban.Plugins.Lifeline, rescue_after: :timer.minutes(60)},
    {Oban.Plugins.Cron,
     crontab:
       [
         {"@daily", ActivityPub.Pruner.PruneDatabaseWorker, max_attempts: 1}
       ] ++
         if Bonfire.Common.Extend.module_enabled?(Bonfire.UI.Common.StaticGenerator) do
           #  generate static pages for guests every X min
           interval = if config_env() == :prod, do: 10, else: 60
           IO.puts("Static pages will be generated and cached every #{interval} minutes.")

           [{"*/#{interval} * * * *", Bonfire.UI.Common.StaticGenerator, max_attempts: 3}]
         else
           IO.puts("Static pages will not be cached")
           []
         end ++
         if Bonfire.Common.Extend.extension_enabled?(:bonfire_open_science) do
           IO.puts("Open science publications will be fetched for all users once an hour.")

           [{"@hourly", Bonfire.OpenScience.APIs}]
         else
           IO.puts("Open science extension is not enabled")
           []
         end}
  ]

config :activity_pub, :oban_queues,
  retries: [federator_incoming: 2, federator_outgoing: 3, remote_fetcher: 1]

config :activity_pub, Oban,
  notifier: Oban.Notifiers.PG,
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
    pool_size =
      case System.get_env("POOL_SIZE") do
        pool when is_binary(pool) and pool not in ["", "0"] ->
          String.to_integer(pool)

        # default to twice the number of CPU cores
        _ ->
          System.schedulers_online() * 2
      end

    # config :bolt_sips, Bolt,
    #   url: url,
    #   basic_auth: [username: "memgraph", password: "memgraph"],
    #   pool_size: pool_size

    config :boltx, Bolt,
      uri: url,
      auth: [username: "memgraph", password: "memgraph"],
      pool_size: pool_size
end

if (config_env() == :prod or System.get_env("OTEL_ENABLED") in yes?) and
     (System.get_env("OTEL_EXPORTER_OTLP_ENDPOINT") || System.get_env("OTEL_LIGHTSTEP_API_KEY") ||
        System.get_env("OTEL_HONEYCOMB_API_KEY")) do
  # Enable tracing only when we have a configured endpoint
  config :opentelemetry,
    span_processor: :batch,
    traces_exporter: {:opentelemetry_exporter, %{}}

  config :opentelemetry_exporter,
    otlp_protocol: :http_protobuf

  otel_endpoint = System.get_env("OTEL_EXPORTER_OTLP_ENDPOINT")

  if otel_endpoint do
    IO.puts("NOTE: OTLP (open telemetry) data will be sent to #{otel_endpoint}")

    config :opentelemetry_exporter,
      otlp_endpoint: otel_endpoint
  end

  config :opentelemetry_exporter,
    # You can configure the compression type for exporting traces.
    otlp_compression: :gzip,
    oltp_traces_compression: :gzip

  if System.get_env("OTEL_LIGHTSTEP_API_KEY") do
    IO.puts("NOTE: OTLP (open telemetry) data will be sent to lightstep / servicenow.com")

    # Example configuration, for more refer to: https://github.com/open-telemetry/opentelemetry-erlang/tree/main/apps/opentelemetry_exporter#application-environment
    config :opentelemetry_exporter,
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
  # Ensure OpenTelemetry is properly disabled when no endpoints are configured
  config :opentelemetry,
    modularity: :disabled,
    span_processor: :simple,
    traces_exporter: :none
end

# Error reporting

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

config :sentry,
  source_code_exclude_patterns: [
    ~r/\/flavours\//,
    ~r/\/extensions\//,
    ~r/\/deps\//,
    ~r/\/_build\//,
    ~r/\/priv\//,
    ~r/\/test\//
  ]

case System.get_env("APPSIGNAL_PUSH_API_KEY", "") do
  "" ->
    config :appsignal, :config, active: false

  api_key ->
    IO.puts("NOTE: errors and performance metrics will be reported to AppSignal.")

    config :appsignal, :config,
      otp_app: :bonfire,
      name: System.get_env("APPSIGNAL_APP_NAME", "bonfire"),
      push_api_key: api_key,
      env: config_env(),
      active: true
end

config :untangle,
  env: config_env(),
  # level: :error,
  to_io: System.get_env("UNTANGLE_TO_IO") in yes?

# start prod-only config
if config_env() == :prod do
  config :bonfire, Bonfire.Common.Repo,
    # ssl: true,
    # database: System.get_env("POSTGRES_DB", "bonfire"),
    # Note: keep this disabled if using ecto_dev_logger or EctoSparkles.Log instead #
    log: String.to_atom(System.get_env("DB_QUERIES_LOG_LEVEL", "false"))
end

# end prod only config

# start prod and dev only config
if config_env() != :test do
  config :bonfire, Bonfire.Common.Repo,
    # The timeout for establishing new connections (default: 5000)
    connect_timeout: String.to_integer(System.get_env("DB_CONNECT_TIMEOUT", "10000")),
    # The time in milliseconds (as an integer) to wait for the query call to finish (default: 15_000)
    timeout: String.to_integer(System.get_env("DB_QUERY_TIMEOUT", "20000")),
    # DBConnection pool tuning - CRITICAL for federation workers under load
    # queue_target: Time a connection checkout request can wait in queue before DBConnection
    # starts to reject new requests. Default is 50ms which is too aggressive for high-concurrency
    # workloads. Setting to 5000ms matches test config and allows patient waiting under load.
    queue_target: String.to_integer(System.get_env("DB_QUEUE_TARGET", "5000")),
    # queue_interval: How often to check if queue_target is being exceeded. Default is 1000ms.
    queue_interval: String.to_integer(System.get_env("DB_QUEUE_INTERVAL", "2000")),
    # pool_timeout: Overall timeout for getting a connection from the pool. Default is 5000ms.
    # Increasing to 30000ms allows workers to wait patiently during load spikes.
    pool_timeout: String.to_integer(System.get_env("DB_POOL_TIMEOUT", "30000")),
    parameters: [
      # Abort any statement that takes more than the specified amount of time. The timeout is measured from the time a command arrives at the server until it is completed by the server.
      statement_timeout: System.get_env("DB_STATEMENT_TIMEOUT", "20000"),
      # idle-in-transaction timeout: terminates any session with an open transaction that has been idle for longer than the specified amount of time. This allows any locks held by that session to be released and the connection slot to be reused. WARNING: this seems to also apply to migrations when running in a release, so needs to be high enough for DB migrations and fixtures to run.
      idle_in_transaction_session_timeout: System.get_env("DB_IDLE_TRANSACTION_TIMEOUT", "120000")
    ]
end

## bonfire_livebook
if Code.ensure_loaded?(Livebook) do
  Livebook.config_runtime()
end

if api_key = System.get_env("PIRATE_WEATHER_API") do
  config :forecastr,
    backend: Forecastr.PirateWeather,
    appid: api_key,
    # minutes to cache
    ttl: to_timeout(minute: 14)
end

if api_key = System.get_env("OPEN_WEATHER_MAP_API_KEY") do
  config :forecastr,
    backend: Forecastr.OWM,
    appid: api_key,
    # minutes to cache
    ttl: to_timeout(minute: 14)
end

IO.puts("Runtime config ready")
