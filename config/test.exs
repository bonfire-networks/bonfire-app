use Mix.Config

alias VoxPublica.{Mailer, Repo}

config :vox_publica, Mailer,
  adapter: Bamboo.TestAdapter

config :logger, level: :warn

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :vox_publica, Repo,
  username: "postgres",
  password: "postgres",
  database: "vox_publica_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: System.get_env("DATABASE_HOST") || "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :cpub_web_phoenix, CommonsPub.WebPhoenix.Endpoint,
  http: [port: 4002],
  server: false

config :argon2_elixir,
  t_cost: 1,
  m_cost: 8
