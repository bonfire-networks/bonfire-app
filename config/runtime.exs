# In this file, we load production configuration and secrets
# from environment variables. You can also hardcode secrets,
# although such is generally not recommended and you have to
# remember to add this file to your .gitignore.
import Config

System.get_env("RELEASING") || System.get_env("DATABASE_URL") || System.get_env("POSTGRES_PASSWORD") ||
    raise """
    environment variable DATABASE_URL is missing.
    For example: ecto://USER:PASS@HOST/DATABASE
    You can also set the host/user/db/password individually.
    """

if System.get_env("DATABASE_URL") do
  config :bonfire, Bonfire.Repo,
    url: System.get_env("DATABASE_URL"),
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")
else
  config :bonfire, Bonfire.Repo,
    # ssl: true,
    username: System.get_env("POSTGRES_USER", "postgres"),
    password: System.get_env("POSTGRES_PASSWORD", "postgres"),
    database: System.get_env("POSTGRES_DB", "bonfire_prod"),
    hostname: System.get_env("POSTGRES_HOST") || "localhost",
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")
end

secret_key_base =
  System.get_env("RELEASING") || System.get_env("SECRET_KEY_BASE") ||
    raise """
    environment variable SECRET_KEY_BASE is missing.
    You can generate one by calling: mix phx.gen.secret
    """

host = System.get_env("HOSTNAME") || "localhost"
port = String.to_integer(System.get_env("PORT") || "4000")

config :bonfire, Bonfire.Web.Endpoint,
  url: [
    host: host,
    port: port
  ],
  http: [
    port: port
  ],
  secret_key_base: secret_key_base

# ## Using releases (Elixir v1.9+)
#
# If you are doing OTP releases, you need to instruct Phoenix
# to start each relevant endpoint:
#

config :bonfire, Bonfire.Web.Endpoint, server: true

#
# Then you can assemble a release by calling `mix release`.
# See `mix help release` for more information.
