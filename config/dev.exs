import Config

config :bonfire, Bonfire.Mailer,
  adapter: Bamboo.LocalAdapter

config :bonfire, Bonfire.Repo,
  username: System.get_env("POSTGRES_USER", "postgres"),
  password: System.get_env("POSTGRES_PASSWORD", "postgres"),
  database: System.get_env("POSTGRES_DB", "bonfire_dev"),
  hostname: System.get_env("POSTGRES_HOST", "localhost"),
  # show_sensitive_data_on_connection_error: true,
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")

config :bonfire, Bonfire.Web.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: [
    node: [
      "node_modules/webpack/bin/webpack.js",
      "--mode",
      "development",
      "--watch-stdin",
      cd: Path.expand("../assets", __DIR__)
    ]
  ]

# ## SSL Support
#
# In order to use HTTPS in development, a self-signed
# certificate can be generated by running the following
# Mix task:
#
#     mix phx.gen.cert
#
# Note that this task requires Erlang/OTP 20 or later.
# Run `mix help phx.gen.cert` for more information.
#
# The `http:` config above can be replaced with:
#
#     https: [
#       port: 4001,
#       cipher_suite: :strong,
#       keyfile: "priv/cert/selfsigned_key.pem",
#       certfile: "priv/cert/selfsigned.pem"
#     ],
#
# If desired, both `http:` and `https:` keys can be
# configured to run both http and https servers on
# different ports.

path_dep_dirs =
  Mess.deps([path: "deps.path"], [])
  |> Enum.map(&(Keyword.fetch!(elem(&1, 1), :path) <> "/lib"))

config :phoenix_live_reload,
  dirs: path_dep_dirs ++ ["lib/"] # watch the app's lib/ dir + the dep/lib/ dir of every locally-cloned dep

path_dep_patterns = path_dep_dirs |> Enum.map(&(String.slice(&1, 2..1000) <>".*ex")) # to include cloned code in patterns

# Watch static and templates for browser reloading.
config :bonfire, Bonfire.Web.Endpoint,
  code_reloader: true,
  live_reload: [
    patterns: [
      # ~r"^priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
      # ~r"^priv/gettext/.*(po)$",
      # ~r"^web/(live|views)/.*ex$",
      # ~r"^lib/.*_live\.ex$",
      # ~r".*leex$",
      ~r"lib/.*ex$",
    ] ++ path_dep_patterns
  ]


config :logger, :console,
  level: :debug,
  # truncate: :infinity,
  format: "[$level] $message\n" # Do not include metadata or timestamps

config :phoenix, :stacktrace_depth, 30

config :phoenix, :plug_init_mode, :runtime

config :exsync,
  src_monitor: true,
  extra_extensions: [".leex", ".js", ".css"]
