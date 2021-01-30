import Config

## Import or set test configs for extensions

import_config "activity_pub_test.exs"

config :bonfire, Bonfire.Mailer, adapter: Bamboo.TestAdapter

config :bonfire_search, disable_indexing: true

## Other general test config

config :logger, level: :warn
# config :logger, level: :notice

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :bonfire, Bonfire.Repo,
  username: "postgres",
  password: System.get_env("POSTGRES_PASSWORD", "postgres"),
  database: "bonfire_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: System.get_env("DATABASE_HOST") || "localhost",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 30

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :bonfire, Bonfire.Web.Endpoint,
  http: [port: 4002],
  server: false

config :bonfire, Oban,
  crontab: false,
  plugins: false,
  queues: false

config :pbkdf2_elixir, :rounds, 1
