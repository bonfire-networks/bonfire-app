import Config

test_instance = System.get_env("TEST_INSTANCE")

yes? = ~w(true yes 1)
# no? = ~w(false no 0)

config :bonfire_open_id,
  templates_path: "lib"

config :boruta, Boruta.Oauth,
  repo: Bonfire.Common.Repo,
  contexts: [
    resource_owners: Bonfire.OpenID
  ]

if config_env() == :test and test_instance not in yes? do
  config :bonfire_open_id, :oauth_module, Boruta.OauthMock
  config :bonfire_open_id, :openid_module, Boruta.OpenidMock
end
