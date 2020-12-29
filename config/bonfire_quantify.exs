use Mix.Config

config :bonfire_quantify,
  web_module: Bonfire.Web,
  endpoint_module: Bonfire.Web.Endpoint,
  repo_module: Bonfire.Repo,
  user_schema: Bonfire.Data.Identity.User,
  # templates_path: "lib",
  otp_app: :bonfire

config :bonfire_quantify, Bonfire.Quantify.Units, valid_contexts: [Bonfire.Quantify.Units, Bonfire.Data.Identity.User]
