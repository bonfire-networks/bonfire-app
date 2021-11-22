import Config

config :activity_pub, ActivityPub.TestRepo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: System.get_env("POSTGRES_PASSWORD", "postgres"),
  database: "bonfire_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: System.get_env("POSTGRES_HOST") || "localhost",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 60

config :activity_pub, ActivityPubWeb.Endpoint,
  http: [port: 4002],
  server: false

config :activity_pub, :adapter, Bonfire.Federate.ActivityPub.Adapter

config :activity_pub, :repo, Bonfire.Repo

config :activity_pub, ecto_repos: [Bonfire.Repo]

config :activity_pub, Oban,
  repo: Bonfire.Repo,
  queues: false

config :activity_pub, :instance, federating: false

config :tesla, adapter: Tesla.Mock

# Print only warnings and errors during test
config :logger, level: :warn
