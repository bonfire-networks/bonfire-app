import Config

config :bonfire_open_id,
  templates_path: "lib"

config :boruta, Boruta.Oauth,
  repo: Bonfire.Common.Repo,
  contexts: [
    resource_owners: Bonfire.OpenID
  ]

if Mix.env() == :test do
  config :bonfire_open_id, :oauth_module, Boruta.OauthMock
  config :bonfire_open_id, :openid_module, Boruta.OpenidMock
end
