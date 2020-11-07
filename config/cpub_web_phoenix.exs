use Mix.Config

signing_salt = System.get_env("SIGNING_SALT", "CqAoopA2")
encryption_salt = System.get_env("ENCRYPTION_SALT", "g7K25as98msad0qlSxhNDwnnzTqklK10")
secret_key_base = System.get_env("SECRET_KEY_BASE", "g7K250qlSxhNDt5qnV6f4HFnyoD7fGUuZ8tbBF69aJCOvUIF8P0U7wnnzTqklK10")

config :cpub_web_phoenix, :signing_salt, signing_salt
config :cpub_web_phoenix, :encryption_salt, encryption_salt
config :cpub_web_phoenix, :routes_module, VoxPublica.Web.Routes
config :cpub_web_phoenix, :routes_helper_module, VoxPublica.Web.Routes.Helpers
config :cpub_web_phoenix, :live_view_module, VoxPublica.Web.PageLive
config :cpub_web_phoenix, :otp_app, :vox_publica

config :cpub_web_phoenix, CommonsPub.WebPhoenix.Endpoint,
  url: [host: "localhost"],
  secret_key_base: secret_key_base,
  render_errors: [view: CommonsPub.WebPhoenix.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: VoxPublica.PubSub,
  live_view: [signing_salt: signing_salt]

config :phoenix, :json_library, Jason
