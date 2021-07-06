# In this file, we load production configuration and secrets
# from environment variables. You can also hardcode secrets,
# although such is generally not recommended and you have to
# remember to add this file to your .gitignore.
import Config

host = System.get_env("HOSTNAME", "localhost")
server_port = String.to_integer(System.get_env("SERVER_PORT", "4000"))
public_port = String.to_integer(System.get_env("PUBLIC_PORT", "4000"))

System.get_env("CI") || System.get_env("DATABASE_URL") || System.get_env("POSTGRES_PASSWORD") ||
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
  System.get_env("CI") || System.get_env("SECRET_KEY_BASE") ||
    raise """
    environment variable SECRET_KEY_BASE is missing.
    You can generate one by calling: mix phx.gen.secret
    """

signing_salt = System.get_env("CI") || System.get_env("SIGNING_SALT") ||
    raise """
    environment variable SIGNING_SALT is missing.
    """

encryption_salt = System.get_env("CI") || System.get_env("ENCRYPTION_SALT") ||
    raise """
    environment variable ENCRYPTION_SALT is missing.
    """

config :bonfire,
  host: host,
  app_name: System.get_env("APP_NAME", "Bonfire"),
  ap_base_path: System.get_env("AP_BASE_PATH", "/pub"),
  github_token: System.get_env("GITHUB_TOKEN"),
  encryption_salt: encryption_salt,
  signing_salt: signing_salt,
  invite_only: System.get_env("INVITE_ONLY", "true") # enable signups?

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

# start test-only config
if config_env() == :test do
  config :bonfire,
    invite_only: false
end

# start prod-only config
if config_env() == :prod do

  config :bonfire, Bonfire.Repo,
    # ssl: true,
    database: System.get_env("POSTGRES_DB", "bonfire"),
    pool_size: String.to_integer(System.get_env("POOL_SIZE", "10")),
    log: String.to_atom(System.get_env("DB_QUERIES_LOG_LEVEL", "debug"))

end # prod only config


# start prod and dev only config
if config_env() != :test do

  config :bonfire, Bonfire.Repo,
    slow_query_ms: String.to_integer(System.get_env("SLOW_QUERY_MS", "100"))


# transactional emails

  mail_blackhole = fn var ->
    IO.puts(
      "WARNING: The environment variable #{var} was not set or was set incorrectly, mail will NOT be sent."
    )

    config :bonfire, Bonfire.Mailer, adapter: Bamboo.LocalAdapter
  end

  mail_mailgun = fn ->
    # API URI depends on whether you're registered with Mailgun in EU, US, etc (defaults to EU)
    base_uri = System.get_env("MAIL_BASE_URI", "https://api.eu.mailgun.net/v3")

    case System.get_env("MAIL_KEY") do
      nil ->
        mail_blackhole.("MAIL_KEY")

      key ->
        case System.get_env("MAIL_DOMAIN") do
          nil ->
            mail_blackhole.("MAIL_DOMAIN")

          domain ->
            case System.get_env("MAIL_FROM") do
              nil ->
                mail_blackhole.("MAIL_FROM")

              from ->
                IO.puts("NOTE: Transactional emails will be sent through Mailgun.")

                config :bonfire, Bonfire.Mailer,
                  adapter: Bamboo.MailgunAdapter,
                  api_key: key,
                  base_uri: base_uri,
                  domain: domain,
                  reply_to: from
            end
        end
    end
  end

  mail_smtp = fn ->
    case System.get_env("MAIL_SERVER") do
      nil ->
        mail_blackhole.("MAIL_SERVER")

      server ->
        case System.get_env("MAIL_DOMAIN") do
          nil ->
            mail_blackhole.("MAIL_DOMAIN")

          domain ->
            case System.get_env("MAIL_USER") do
              nil ->
                mail_blackhole.("MAIL_USER")

              user ->
                case System.get_env("MAIL_PASSWORD") do
                  nil ->
                    mail_blackhole.("MAIL_PASSWORD")

                  password ->
                    case System.get_env("MAIL_FROM") do
                      nil ->
                        mail_blackhole.("MAIL_FROM")

                      from ->
                        IO.puts("NOTE: Transactional emails will be sent through SMTP.")

                        config :bonfire, Bonfire.Mailer,
                          adapter: Bamboo.SMTPAdapter,
                          server: server,
                          hostname: domain,
                          port: String.to_integer(System.get_env("MAIL_PORT", "587")),
                          username: user,
                          password: password,
                          tls: :always,
                          allowed_tls_versions: [:"tlsv1.2"],
                          ssl: false,
                          retries: 1,
                          auth: :always,
                          reply_to: from
                    end
                end
            end
        end
    end
  end

  case System.get_env("MAIL_BACKEND") do
    "mailgun" -> mail_mailgun.()
    "smtp" -> mail_smtp.()
    _ -> mail_blackhole.("MAIL_BACKEND")
  end

end

### copy-paste Bonfire extension configs that need to read env at runtime

## bonfire_search
config :bonfire_search,
  disable_indexing: System.get_env("SEARCH_INDEXING_DISABLED", "false"),
  instance: System.get_env("SEARCH_MEILI_INSTANCE", "http://localhost:7700"), # protocol, hostname and port
  api_key: System.get_env("MEILI_MASTER_KEY", "make-sure-to-change-me") # secret key

## bonfire_livebook
if Code.ensure_loaded?(Livebook.Config) do
  config :livebook, :root_path, Livebook.Config.root_path!("LIVEBOOK_ROOT_PATH")

  if password = Livebook.Config.password!("LIVEBOOK_PASSWORD") do
    config :livebook, authentication_mode: :password, password: password
  else
    config :livebook, authentication_mode: :token
    config :livebook, token: System.get_env("LIVEBOOK_TOKEN", Livebook.Utils.random_id())
  end

  config :livebook,
        :cookie,
        Livebook.Config.cookie!("LIVEBOOK_COOKIE") || Livebook.Utils.random_cookie()

  config :livebook,
        :default_runtime,
        Livebook.Config.default_runtime!("LIVEBOOK_DEFAULT_RUNTIME") ||
          {Livebook.Runtime.Embedded, []}

end
