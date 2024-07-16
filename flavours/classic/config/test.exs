import Config

test_instance? = System.get_env("TEST_INSTANCE") == "yes"
federate? = test_instance? or System.get_env("FEDERATE") == "yes"

## Import or set test configs for extensions

import_config "activity_pub_test.exs"

config :bonfire,
  # should match limit hardcoded in tests
  default_pagination_limit: 2,
  # should match limit hardcoded in tests
  pagination_hard_max_limit: 2,
  skip_all_boundary_checks: false

config :bonfire, Bonfire.Mailer, adapter: Bamboo.TestAdapter

config :bonfire_search,
  modularity: :disabled

## Other general test config

truncate =
  case System.get_env("TEST_LOG_TRUNCATE", "2000") do
    "0" -> :infinity
    truncate -> String.to_integer(truncate)
  end

config :logger,
  level: String.to_existing_atom(System.get_env("TEST_LOG_LEVEL", "info")),
  truncate: truncate

config :logger, :console, truncate: truncate

if !test_instance? and System.get_env("CAPTURE_LOG") != "no" do
  # to suppress non-captured logs in tests (eg. in setup_all)
  config :logger, backends: []
end

# Configure your database
# db = "bonfire_test#{System.get_env("MIX_TEST_PARTITION")}"
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :bonfire_umbrella, Bonfire.Common.Repo,
  pool: Ecto.Adapters.SQL.Sandbox,
  # show_sensitive_data_on_connection_error: true,
  # database: db,
  slow_query_ms: 500,
  queue_target: 5_000,
  queue_interval: 2_000,
  timeout: 50_000,
  connect_timeout: 10_000,
  ownership_timeout: 100_000,
  # log: :info,
  log: false,
  stacktrace: true

config :tesla,
  adapter: if(federate?, do: {Tesla.Adapter.Finch, name: Bonfire.Finch}, else: Tesla.Mock)

#  enable federation in tests, since we're either using mocks or integration testing with TEST_INSTANCE 
config :activity_pub, :instance, federating: true

oban_mode = if(federate?, do: :inline, else: :manual)
config :bonfire, Oban, testing: oban_mode
config :activity_pub, Oban, testing: oban_mode

config :activity_pub, :disable_cache, test_instance?

if test_instance? do
  config :logger, :console,
    format: "[$level $metadata] $message\n",
    metadata: [:instance, :action]
else
  config :logger, :console,
    format: "[$level $metadata] $message\n",
    metadata: [:action, :pid]
end

config :phoenix_test, :endpoint, Bonfire.Web.Endpoint

config :pbkdf2_elixir, :rounds, 1

config :mix_test_interactive,
  clear: true

config :paginator, Paginator.Repo,
  pool: Ecto.Adapters.SQL.Sandbox,
  username: System.get_env("POSTGRES_USER", "postgres"),
  password: System.get_env("POSTGRES_PASSWORD", "postgres"),
  hostname: System.get_env("POSTGRES_HOST", "localhost")

# database: db

config :exsync,
  src_monitor: false,
  extra_extensions: [".leex", ".heex", ".js", ".css", ".sface"]

# use Ecto sandbox?
config :bonfire,
  sql_sandbox: System.get_env("PHX_SERVER") != "yes" and System.get_env("TEST_INSTANCE") != "yes"

{chromedriver_path, _} = System.cmd("sh", ["-c", "command -v chromedriver"])

chromedriver_path =
  (chromedriver_path || "/usr/local/bin/chromedriver")
  |> String.trim()
  |> IO.inspect(label: "chromedriver_path")

config :wallaby,
  otp_app: :bonfire,
  # base_url: Bonfire.Web.Endpoint.url(),
  max_wait_time: 6_000,
  screenshot_on_failure: true,
  chromedriver: [
    # point to your chromedriver path
    path: chromedriver_path,
    # change to false if you want to see the browser in action
    headless: true
  ]

config :phoenix_live_view, debug_heex_annotations: true
