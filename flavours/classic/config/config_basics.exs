import Config

config :phoenix, :json_library, Jason

config :ecto_sparkles, :otp_app, :bonfire
config :ecto_sparkles, :env, config_env()
config :ecto_sparkles, :umbrella_otp_app, :bonfire_umbrella
