import Config

config :activity_pub, :instance,
  federating: false,
  disable_test_apps: true,
  adapter: Bonfire.Federate.ActivityPub.Adapter

# rewrite_policy: [ActivityPub.MRF.SimplePolicy]

config :activity_pub, :repo, Bonfire.Common.Repo
config :activity_pub, ecto_repos: [Bonfire.Common.Repo]
config :activity_pub, :endpoint_module, Bonfire.Web.Endpoint

config :activity_pub, Oban,
  repo: Bonfire.Common.Repo,
  queues: false

config :tesla, adapter: Tesla.Mock

# Print only warnings and errors during test
config :logger, level: :warn

config :activity_pub, ActivityPubWeb.Endpoint,
  http: [port: 4000],
  server: false
