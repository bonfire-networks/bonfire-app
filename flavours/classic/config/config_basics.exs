import Config

config :phoenix, :json_library, Jason

config :bonfire_common, :otp_app, :bonfire

config :ecto_sparkles, :otp_app, :bonfire
config :ecto_sparkles, :env, config_env()
config :ecto_sparkles, :umbrella_otp_app, :bonfire_umbrella

# Choose password hashing backend
# Note that this corresponds with our dependencies in mix.exs
hasher = if config_env() in [:dev, :test], do: Pbkdf2, else: Argon2

config :bonfire_data_identity, Bonfire.Data.Identity.Credential, hasher_module: hasher
