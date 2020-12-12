use Mix.Config

config :bonfire_quantify,
  web_module: Bonfire.Web,
  repo_module: Bonfire.Repo,
  user_schema: Bonfire.Data.Identity.User,
  # templates_path: "lib",
  otp_app: :bonfire
