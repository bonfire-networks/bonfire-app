import Config

## Import or set test configs for extensions

import_config "activity_pub_test.exs"

config :bonfire,
  default_pagination_limit: 10, # should match limit hardcoded in tests
  thread_default_pagination_limit: 10, # should match limit hardcoded in tests
  skip_all_boundary_checks: false

config :bonfire, Bonfire.Mailer, adapter: Bamboo.TestAdapter

config :bonfire_search,
  disabled: true,
  disable_indexing: true

## Other general test config

config :logger, level: :info
# config :logger, level: :debug
# config :logger, level: :notice
config :logger, truncate: :infinity
config :logger, :console, truncate: :infinity

# Configure your database
db = "bonfire_test#{System.get_env("MIX_TEST_PARTITION")}"
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :bonfire, Bonfire.Common.Repo,
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 20,
  # show_sensitive_data_on_connection_error: true,
  database: db,
  slow_query_ms: 500,
  queue_target: 5_000,
  queue_interval: 2_000,
  timeout: 10_000,
  connect_timeout: 10_000

config :bonfire, Bonfire.Web.Endpoint,
  http: [port: 4001]

config :bonfire, Oban,
  crontab: false,
  plugins: false,
  queues: false

config :pbkdf2_elixir, :rounds, 1

config :mix_test_interactive,
  clear: true

config :paginator, ecto_repos: [Bonfire.Common.Repo]
config :paginator, Paginator.Repo,
  pool: Ecto.Adapters.SQL.Sandbox,
  username: System.get_env("POSTGRES_USER", "postgres"),
  password: System.get_env("POSTGRES_PASSWORD", "postgres"),
  hostname: System.get_env("POSTGRES_HOST", "localhost"),
  database: db

config :exsync,
  src_monitor: false,
  extra_extensions: [".leex", ".js", ".css", ".sface"]


# for headless browser testing:
config :bonfire, sql_sandbox: true
config :wallaby,
  otp_app: :bonfire,
  # base_url: Bonfire.Web.Endpoint.url(),
  max_wait_time: 6_000,
  screenshot_on_failure: true,
  chromedriver: [
    path: "assets/node_modules/chromedriver/bin/chromedriver", # point to your chromedriver path
    headless: true # change to false if you want to see the browser in action
  ]
