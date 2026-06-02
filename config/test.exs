import Config

yes? = ~w(true yes 1)
no? = ~w(false no 0)

test_instance? = System.get_env("TEST_INSTANCE") in yes?
federate? = test_instance? or System.get_env("FEDERATE") in yes?
lightweight_test? = System.get_env("BONFIRE_LIGHTWEIGHT_TEST_SETUP") == "1"

## Import or set test configs for extensions

import_config "activity_pub_test.exs"

config :bonfire,
  # should match limit hardcoded in tests
  default_pagination_limit: 2,
  pagination_hard_max_limit: 20,
  skip_all_boundary_checks: false,
  ui: [infinite_scroll: false]

if lightweight_test? do
  repo_config = [
    database: System.get_env("POSTGRES_DB", "bonfire_test"),
    username: System.get_env("POSTGRES_USER", "postgres"),
    password: System.get_env("POSTGRES_PASSWORD", "postgres"),
    hostname: System.get_env("POSTGRES_HOST", "localhost"),
    port: System.get_env("POSTGRES_PORT", "5432") |> String.to_integer(),
    types: Postgrex.DefaultTypes,
    timeout: System.get_env("DB_QUERY_TIMEOUT", "20000") |> String.to_integer(),
    pool_timeout: System.get_env("DB_POOL_TIMEOUT", "30000") |> String.to_integer(),
    ownership_timeout: System.get_env("DB_OWNERSHIP_TIMEOUT", "100000") |> String.to_integer(),
    queue_target: System.get_env("DB_QUEUE_TARGET", "5000") |> String.to_integer(),
    queue_interval: System.get_env("DB_QUEUE_INTERVAL", "2000") |> String.to_integer(),
    parameters: [
      statement_timeout: System.get_env("DB_STATEMENT_TIMEOUT", "20000"),
      idle_in_transaction_session_timeout: System.get_env("DB_IDLE_TRANSACTION_TIMEOUT", "120000")
    ]
  ]

  config :bonfire, Bonfire.Common.Repo, repo_config
  config :bonfire, Bonfire.Common.TestInstanceRepo, repo_config
end

config :bonfire_mailer, Bonfire.Mailer.Bamboo, adapter: Bamboo.TestAdapter
config :bonfire_mailer, Bonfire.Mailer.Swoosh, adapter: Swoosh.Adapters.Test

config :bonfire_common, Bonfire.Common.AntiSpam, service: Bonfire.Common.AntiSpam.Mock

# use DB based search in tests by default
config :bonfire_search, adapter: nil

## Other general test config

log_level = String.to_existing_atom(System.get_env("TEST_LOG_LEVEL", "info"))

truncate =
  case System.get_env("TEST_LOG_TRUNCATE", "2000") do
    "0" -> :infinity
    truncate -> String.to_integer(truncate)
  end

config :logger,
  level: log_level,
  truncate: truncate

config :surface,
  log_level: log_level

config :logger, :console, truncate: truncate

if !test_instance? and System.get_env("CAPTURE_LOG") not in no? and
     System.get_env("UNTANGLE_TO_IO") not in yes? do
  # to suppress non-captured logs in tests (eg. in setup_all)
  config :logger, :default_handler, false
end

if !federate? do
  config :tesla,
    adapter: Tesla.Mock
end

# Configure Req.Test stubs
config :bonfire_rss, :req_options, plug: {Req.Test, Bonfire.RSS}

# enable federation in full tests; lightweight local setup only enables it when explicitly requested
config :activity_pub, :instance, federating: if(lightweight_test?, do: federate?, else: true)

oban_mode = if(federate?, do: :inline, else: :manual)
config :bonfire, Oban, testing: oban_mode
config :activity_pub, Oban, testing: oban_mode

config :activity_pub, :disable_cache, test_instance?

if test_instance? do
  config :logger, :console,
    format: "[$level $metadata] $message\n",
    metadata: [:instance, :action]
else
  config :logger, :console,
    format: "[$level $metadata] $message\n",
    metadata: [:action, :pid]
end

config :phoenix_test, :endpoint, Bonfire.Web.Endpoint

# use Ecto Repo sandbox?
config :bonfire,
  sql_sandbox:
    System.get_env("PHX_SERVER") not in yes? and
      System.get_env("TEST_INSTANCE") not in yes?

config :pbkdf2_elixir, :rounds, 1

config :argon2_elixir,
  t_cost: 1,
  m_cost: 8

config :mix_test_interactive,
  clear: true

config :exsync,
  src_monitor: false,
  extra_extensions: [".leex", ".heex", ".js", ".css", ".sface"]

{chromedriver_path, _} = System.cmd("sh", ["-c", "command -v chromedriver"])

chromedriver_path =
  (chromedriver_path || "/usr/local/bin/chromedriver")
  |> String.trim()
  |> IO.inspect(label: "chromedriver_path")

config :wallaby,
  otp_app: :bonfire,
  # base_url: Bonfire.Web.Endpoint.url(),
  max_wait_time: to_timeout(second: 6),
  screenshot_on_failure: true,
  chromedriver: [
    # point to your chromedriver path
    path: chromedriver_path,
    # change to false if you want to see the browser in action
    headless: true
  ]

config :phoenix_live_view, debug_heex_annotations: true
