import Config

## Import or set test configs for extensions

import_config "activity_pub_test.exs"

config :bonfire, Bonfire.Mailer, adapter: Bamboo.TestAdapter

config :bonfire_search,
  disabled: true,
  disable_indexing: true

## Other general test config

config :logger, level: :info
# config :logger, level: :notice

# Configure your database
# db = "bonfire_test#{System.get_env("MIX_TEST_PARTITION")}"
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :bonfire, Bonfire.Common.Repo,
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 60,
  # show_sensitive_data_on_connection_error: true,
  # database: db,
  slow_query_ms: 500

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :bonfire, Bonfire.Web.Endpoint,
  http: [port: 4001],
  server: false

config :bonfire, Oban, testing: :manual

config :pbkdf2_elixir, :rounds, 1

config :mix_test_interactive,
  clear: true

config :paginator, ecto_repos: [Bonfire.Common.Repo]

config :paginator, Paginator.Repo,
  pool: Ecto.Adapters.SQL.Sandbox,
  username: System.get_env("POSTGRES_USER", "postgres"),
  password: System.get_env("POSTGRES_PASSWORD", "postgres"),
  hostname: System.get_env("POSTGRES_HOST", "localhost")

# database: db
