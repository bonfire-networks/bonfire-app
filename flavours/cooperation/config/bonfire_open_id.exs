import Config

config :bonfire_open_id,
  templates_path: "lib"

config :boruta, Boruta.Oauth,
  repo: Bonfire.Common.Repo,
  issuer: "https://bonfirenetworks.org",
  contexts: [
    resource_owners: Bonfire.OpenID.Integration
  ]
