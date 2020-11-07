use Mix.Config

signing_salt = System.get_env("SIGNING_SALT", "CqAoopA2")
encryption_salt = System.get_env("ENCRYPTION_SALT", "g7K25as98msad0qlSxhNDwnnzTqklK10")
secret_key_base = System.get_env("SECRET_KEY_BASE", "g7K250qlSxhNDt5qnV6f4HFnyoD7fGUuZ8tbBF69aJCOvUIF8P0U7wnnzTqklK10")

config :bonfire_web_phoenix, :signing_salt, signing_salt
config :bonfire_web_phoenix, :encryption_salt, encryption_salt
config :bonfire_web_phoenix, :routes_module, Bonfire.Web.Routes
config :bonfire_web_phoenix, :routes_helper_module, Bonfire.Web.Routes.Helpers
config :bonfire_web_phoenix, :live_view_module, Bonfire.Web.PageLive
config :bonfire_web_phoenix, :otp_app, :bonfire

config :bonfire_web_phoenix, Bonfire.WebPhoenix.Endpoint,
  url: [host: "localhost"],
  secret_key_base: secret_key_base,
  render_errors: [view: Bonfire.WebPhoenix.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Bonfire.PubSub,
  live_view: [signing_salt: signing_salt]

config :phoenix, :json_library, Jason
