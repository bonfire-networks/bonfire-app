use Mix.Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :activity_pub, ActivityPubWeb.Endpoint,
  http: [port: 4002],
  server: false

config :activity_pub, :adapter, Bonfire.Federate.ActivityPub.Adapter

config :activity_pub, :repo, Bonfire.Repo

config :activity_pub,
  ecto_repos: [Bonfire.Repo]

config :activity_pub, Oban,
  repo: Bonfire.Repo,
  queues: false

config :activity_pub, :instance, federating: false

config :tesla, adapter: Tesla.Mock

# Print only warnings and errors during test
config :logger, level: :warn
