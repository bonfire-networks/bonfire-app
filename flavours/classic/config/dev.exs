import Config

config :bonfire,
  experimental_features_enabled: false,
  default_pagination_limit: 5 # low limit so it is easier to test

# config :pseudo_gettext, :locale, "en-pseudo_text" # uncomment to use https://en.wikipedia.org/wiki/Pseudolocalization and check that the app is properly localisable

config :bonfire, Bonfire.Common.Repo,
  database: System.get_env("POSTGRES_DB", "bonfire_dev"),
  # show_sensitive_data_on_connection_error: true,
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
  log: false

path_dep_dirs =
  Mess.deps([path: "deps.path"], [])
  |> Enum.map(&(Keyword.fetch!(elem(&1, 1), :path) <> "/lib"))

config :phoenix_live_reload,
  dirs: path_dep_dirs ++ ["lib/"] # watch the app's lib/ dir + the dep/lib/ dir of every locally-cloned dep

path_dep_patterns = path_dep_dirs |> Enum.map(&(String.slice(&1, 2..1000) <>".*ex")) # to include cloned code in patterns
path_dep_patterns = path_dep_patterns ++ path_dep_dirs |> Enum.map(&(String.slice(&1, 2..1000) <>".*sface")) # Surface views

# Watch static and templates for browser reloading.
config :bonfire, Bonfire.Web.Endpoint,
  server: true,
  debug_errors: false, # In the development environment, Phoenix will debug errors by default, showing us a very informative debugging page. If we want to see what the application would serve in production, set to false
  check_origin: false,
  code_reloader: true,
  watchers: [
    # yarn: [
    #   "watch",
    #   cd: Path.expand("assets", File.cwd!())
    # ],
    yarn: [
      "watch.js",
      cd: Path.expand("assets", File.cwd!())
    ],
    yarn: [
      "watch.css",
      cd: Path.expand("assets", File.cwd!())
    ],
    yarn: [
      "watch.assets",
      cd: Path.expand("assets", File.cwd!())
    ]
  ],
  live_reload: [
    patterns: [
      # ~r"^priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
      # ~r"^priv/gettext/.*(po)$",
      # ~r"^web/(live|views)/.*ex$",
      # ~r"^lib/.*_live\.ex$",
      # ~r".*leex$",
      ~r"lib/.*ex$",
      ~r".*sface$",
      ~r"priv/catalogue/.*(ex)$",
    ] ++ path_dep_patterns
  ]

# defp elixirc_paths(:dev), do: ["lib"] ++ catalogues()

config :logger, :console,
  level: :debug,
  truncate: :infinity,
  format: "[$level] $message\n" # Do not include metadata or timestamps

config :phoenix, :stacktrace_depth, 30

config :phoenix, :plug_init_mode, :runtime

config :surface, :compiler,
    warn_on_undefined_props: true

config :exsync,
  src_monitor: true,
  extra_extensions: [".leex", ".js", ".css", ".sface"]
