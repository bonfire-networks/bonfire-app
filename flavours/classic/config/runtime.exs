# In this file, we load production configuration and secrets
# from environment variables. You can also hardcode secrets,
# although such is generally not recommended and you have to
# remember to add this file to your .gitignore.
import Config

if config_env() == :prod do

  host = System.get_env("HOSTNAME", "localhost")
  port = String.to_integer(System.get_env("PORT", "4000"))

  System.get_env("RELEASING") || System.get_env("DATABASE_URL") || (System.get_env("POSTGRES_DB") && System.get_env("POSTGRES_PASSWORD")) ||
      raise """
      Environment variables for database are missing.
      For example: DATABASE_URL=ecto://USER:PASS@HOST/DATABASE
      You can also set POSTGRES_DB and POSTGRES_PASSWORD (required),
      and POSTGRES_USER (default: postgres) and POSTGRES_HOST (default: localhost)
      """

  if System.get_env("DATABASE_URL") do
    config :bonfire, Bonfire.Repo,
      url: System.get_env("DATABASE_URL"),
      pool_size: String.to_integer(System.get_env("POOL_SIZE", "10"))
  else
    config :bonfire, Bonfire.Repo,
      # ssl: true,
      username: System.get_env("POSTGRES_USER", "postgres"),
      password: System.get_env("POSTGRES_PASSWORD", "postgres"),
      database: System.get_env("POSTGRES_DB", "bonfire"),
      hostname: System.get_env("POSTGRES_HOST", "localhost"),
      pool_size: String.to_integer(System.get_env("POOL_SIZE", "10"))
  end

  secret_key_base =
    System.get_env("RELEASING") || System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  signing_salt = System.get_env("RELEASING") || System.get_env("SIGNING_SALT") ||
      raise """
      environment variable SIGNING_SALT is missing.
      """

  encryption_salt = System.get_env("RELEASING") || System.get_env("ENCRYPTION_SALT") ||
      raise """
      environment variable ENCRYPTION_SALT is missing.
      """

  config :bonfire, :signing_salt, signing_salt
  config :bonfire, :encryption_salt, encryption_salt

  config :bonfire, Bonfire.Web.Endpoint,
    url: [
      host: host,
      port: port
    ],
    http: [
      port: port
    ],
    secret_key_base: secret_key_base,
    live_view: [signing_salt: signing_salt]

  # ## Using releases (Elixir v1.9+)
  #
  # If you are doing OTP releases, you need to instruct Phoenix
  # to start each relevant endpoint:
  #

  config :bonfire, Bonfire.Web.Endpoint, server: true

  #
  # Then you can assemble a release by calling `mix release`.
  # See `mix help release` for more information.

end # end prod-only config
