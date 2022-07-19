# In this file, we load production configuration and secrets
# from environment variables. You can also hardcode secrets,
# although such is generally not recommended and you have to
# remember to add this file to your .gitignore.
import Config

host = System.get_env("HOSTNAME", "localhost")
server_port = String.to_integer(System.get_env("SERVER_PORT", "4000"))
public_port = String.to_integer(System.get_env("PUBLIC_PORT", "4000"))

## load runtime configs directly via extension-provided modules
Bonfire.Common.Config.LoadExtensionsConfig.load_configs()
##

System.get_env("DATABASE_URL") || System.get_env("POSTGRES_PASSWORD") || System.get_env("CI") ||
    raise """
    Environment variables for database are missing.
    For example: DATABASE_URL=ecto://USER:PASS@HOST/DATABASE
    You can also set POSTGRES_PASSWORD (required),
    and POSTGRES_USER (default: postgres) and POSTGRES_HOST (default: localhost)
    """

if System.get_env("DATABASE_URL") do
  config :bonfire, Bonfire.Common.Repo,
    url: System.get_env("DATABASE_URL")
else
  config :bonfire, Bonfire.Common.Repo,
    # ssl: true,
    username: System.get_env("POSTGRES_USER", "postgres"),
    password: System.get_env("POSTGRES_PASSWORD", "postgres"),
    hostname: System.get_env("POSTGRES_HOST", "localhost")
end

secret_key_base =
  System.get_env("SECRET_KEY_BASE") || System.get_env("CI") ||
    raise """
    environment variable SECRET_KEY_BASE is missing.
    You can generate one by calling: mix phx.gen.secret
    """

signing_salt = System.get_env("SIGNING_SALT") || System.get_env("CI") ||
    raise """
    environment variable SIGNING_SALT is missing.
    """

encryption_salt = System.get_env("ENCRYPTION_SALT") || System.get_env("CI") ||
    raise """
    environment variable ENCRYPTION_SALT is missing.
    """

config :bonfire,
  host: host,
  app_name: System.get_env("APP_NAME", "Bonfire"),
  ap_base_path: System.get_env("AP_BASE_PATH", "/pub"),
  github_token: System.get_env("GITHUB_TOKEN"),
  show_debug_errors_in_dev: System.get_env("SHOW_DEBUG_IN_DEV"),
  encryption_salt: encryption_salt,
  signing_salt: signing_salt

start_server? = if config_env() == :test, do: System.get_env("START_SERVER", "true"), else: System.get_env("START_SERVER", "true")

config :bonfire, Bonfire.Web.Endpoint,
  server: String.to_existing_atom(start_server?),
  url: [
    host: host,
    port: public_port
  ],
  http: [
    port: server_port
  ],
  secret_key_base: secret_key_base,
  live_view: [signing_salt: signing_salt]

if System.get_env("SENTRY_DSN") do
  IO.puts(
    "Note: errors will be reported to Sentry."
  )

  config :sentry,
    dsn: System.get_env("SENTRY_DSN")

  if System.get_env("SENTRY_NAME") do
    config :sentry, server_name: System.get_env("SENTRY_NAME")
  end
end

# start prod-only config
if config_env() == :prod do

  config :bonfire, Bonfire.Common.Repo,
    # ssl: true,
    database: System.get_env("POSTGRES_DB", "bonfire"),
    pool_size: String.to_integer(System.get_env("POOL_SIZE", "10")),
    log: String.to_atom(System.get_env("DB_QUERIES_LOG_LEVEL", "false")) # Note: keep this disabled if using ecto_dev_logger or EctoSparkles.Log instead #

end # prod only config


# start prod and dev only config
if config_env() != :test do

  config :bonfire, Bonfire.Common.Repo,
    slow_query_ms: String.to_integer(System.get_env("SLOW_QUERY_MS", "100"))

end

## bonfire_livebook
if Code.ensure_loaded?(Livebook) do
  Livebook.config_runtime()
end

IO.puts(
  "Welcome to Bonfire!"
)
