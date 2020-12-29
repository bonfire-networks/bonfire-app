use Mix.Config

config :bonfire_classify,
  otp_app: :your_app_name,
  web_module: Bonfire.Web,
  repo_module: Bonfire.Repo,
  user_schema: Bonfire.Data.Identity.User,
  templates_path: "lib"
