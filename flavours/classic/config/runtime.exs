# In this file, we load production configuration and secrets
# from environment variables. You can also hardcode secrets,
# although such is generally not recommended and you have to
# remember to add this file to your .gitignore.
import Config

host = System.get_env("HOSTNAME", "localhost")
server_port = String.to_integer(System.get_env("SERVER_PORT", "4000"))
public_port = String.to_integer(System.get_env("PUBLIC_PORT", "4000"))

System.get_env("RELEASING") || System.get_env("DATABASE_URL") || System.get_env("POSTGRES_PASSWORD") ||
    raise """
    Environment variables for database are missing.
    For example: DATABASE_URL=ecto://USER:PASS@HOST/DATABASE
    You can also set POSTGRES_PASSWORD (required),
    and POSTGRES_USER (default: postgres) and POSTGRES_HOST (default: localhost)
    """

if System.get_env("DATABASE_URL") do
  config :bonfire, Bonfire.Repo,
    url: System.get_env("DATABASE_URL")
else
  config :bonfire, Bonfire.Repo,
    # ssl: true,
    username: System.get_env("POSTGRES_USER", "postgres"),
    password: System.get_env("POSTGRES_PASSWORD", "postgres"),
    hostname: System.get_env("POSTGRES_HOST", "localhost")
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

config :bonfire,
  host: host,
  app_name: System.get_env("APP_NAME", "Bonfire"),
  ap_base_path: System.get_env("AP_BASE_PATH", "/pub"),
  github_token: System.get_env("GITHUB_TOKEN"),
  encryption_salt: encryption_salt,
  signing_salt: signing_salt

config :bonfire, Bonfire.Web.Endpoint,
  url: [
    host: host,
    port: public_port
  ],
  http: [
    port: server_port
  ],
  secret_key_base: secret_key_base,
  live_view: [signing_salt: signing_salt]


# start prod-only config
if config_env() == :prod do

  config :bonfire, Bonfire.Repo,
    # ssl: true,
    database: System.get_env("POSTGRES_DB", "bonfire"),
    pool_size: String.to_integer(System.get_env("POOL_SIZE", "10"))

end # prod only config
