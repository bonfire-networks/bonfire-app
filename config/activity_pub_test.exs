import Config

config :activity_pub, :instance,
  disable_test_apps: true,
  adapter: Bonfire.Federate.ActivityPub.Adapter

# rewrite_policy: [ActivityPub.MRF.SimplePolicy]

# in tests, *also* apply the lib's own config-based `SimplePolicy` (`:mrf_simple`) reject on top of
# the boundary-based gating in `Bonfire.Federate.ActivityPub.Adapter`, so AP-lib tests that rely on
# `:mrf_simple` (which the host adapter doesn't consult) behave as the lib expects
config :activity_pub, :also_apply_simple_policy, true

config :activity_pub, :repo, Bonfire.Common.Repo
config :activity_pub, ecto_repos: [Bonfire.Common.Repo]
config :activity_pub, :endpoint_module, Bonfire.Web.Endpoint

config :activity_pub, Oban, repo: Bonfire.Common.Repo

# Print only warnings and errors during test
config :logger, level: :warn

config :activity_pub, ActivityPub.Web.Endpoint,
  http: [port: 4000],
  server: false
