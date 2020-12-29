use Mix.Config

config :bonfire_geolocate,
  web_module: Bonfire.Web,
  endpoint_module: Bonfire.Web.Endpoint,
  repo_module: Bonfire.Repo,
  user_schema: Bonfire.Data.Identity.User
