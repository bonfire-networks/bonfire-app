import Config

config :activity_pub, :adapter, Bonfire.Federate.ActivityPub.Adapter
config :activity_pub, :instance, federating: false
# rewrite_policy: [ActivityPub.MRF.SimplePolicy]
config :activity_pub, :disable_test_apps, true

config :tesla, adapter: Tesla.Mock

# Print only warnings and errors during test
config :logger, level: :warn

config :activity_pub, ActivityPubWeb.Endpoint,
  http: [port: 4000],
  server: false
