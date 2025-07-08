import Config

config :bonfire,
  # Note: you can run `Bonfire.Common.Config.put(:experimental_features_enabled, true)` to enable these in prod too
  experimental_features_enabled: true,
  # low limit so it is easier to test UX
  # default_pagination_limit: 10,
  ui: [
    feed_object_extension_preloads_disabled: false
  ]

federate? = System.get_env("FEDERATE") == "yes"

config :activity_pub, :instance, federating: federate?

# only sign fetches when federating (which hopefully means we have a public domain name so signature key can be verified)
config :activity_pub, sign_object_fetches: federate?

# config :pseudo_gettext, :locale, "en-pseudo_text" # uncomment to use https://en.wikipedia.org/wiki/Pseudolocalization and check that the app is properly localisable

config :bonfire, Bonfire.Common.Repo,
  database: System.get_env("POSTGRES_DB", "bonfire_dev"),
  # show_sensitive_data_on_connection_error: true,
  # EctoSparkles does the logging instead
  log: false,
  stacktrace: true

# Disable live_debugger to prevent ETS table errors
config :live_debugger, disabled?: true

# if System.get_env("WITH_FORKS", "1") == "1" , do:
# Mess.deps(
#   [path: Path.relative_to_cwd("config/deps.path")],
#   []
# ),
# else: []

use_cowboy? = System.get_env("PLUG_SERVER") != "bandit"
max_requests = 1

# Watch static and templates for browser reloading.
config :bonfire, Bonfire.Web.Endpoint,
  server: true,
  #  show special Phoenix error pages instead of custom Bonfire ones?
  debug_errors: System.get_env("DEV_DEBUG_ERRORS", "1") != "0",
  check_origin: false,
  http:
    if(use_cowboy?,
      do: [protocol_options: [idle_timeout: 120_000]],
      else: [
        http_1_options: [max_requests: max_requests],
        http_1_options: [max_requests: max_requests]
      ]
    )

if System.get_env("HOT_CODE_RELOAD") != "-1" do
  enable_reloader? = System.get_env("HOT_CODE_RELOAD") != "0" and Mix.target() != :app

  config :bonfire, :hot_code_reload, enable_reloader?

  local_deps =
    if Code.ensure_loaded?(Mess),
      do:
        Mess.read_umbrella(
          config_dir: if(File.exists?("config/deps.git"), do: "config/", else: "./"),
          use_local_forks?: System.get_env("WITH_FORKS", "1") == "1"
        ),
      else: []

  local_dep_names = Enum.map(local_deps, &elem(&1, 0))

  dep_paths =
    Enum.map(local_deps, fn dep ->
      case elem(dep, 1)[:path] do
        nil -> nil
        path -> "#{path}/lib"
      end
    end)
    |> Enum.reject(&is_nil/1)

  watch_paths = dep_paths ++ ["lib/"] ++ ["priv/static/"]

  IO.puts("Watching these deps for code reloading: #{inspect(local_dep_names)}")

  config :phoenix_live_reload,
    # watch the app's lib/ dir + the dep/lib/ dir of every locally-cloned dep
    dirs: watch_paths

  # filename patterns that should trigger hots reloads of components/CSS/etc (only within the above dirs)
  hot_patterns = [
    ~r"(_live|_view|_styles)\.ex$",
    ~r{(live|views|pages|components|themes)/.*(ex|css)$},
    ~r".*(heex|leex|sface|neex|hooks.js|swiftui.*)$",
    ~r"priv/catalogue/.*(ex)$",
    ~r"priv/static/.*styles$"
  ]

  # filename patterns that should trigger full page reloads (only within the above dirs)
  patterns = [
    ~r"^priv/static/.*(js|css|png|jpeg|jpg|gif|svg|webp)$",
    # ~r"^priv/gettext/.*(po)$",
    ~r{(web|templates)/.*(ex)$},
    ~r"(live_handler|live_handlers|routes)\.ex$"
  ]

  if Code.ensure_loaded?(Bonfire.Mixer),
    do: Bonfire.Mixer.log(patterns, "Watching these filenames for live reloading in the browser")

  config :bonfire, Bonfire.Web.Endpoint,
    code_reloader: enable_reloader?,
    # TEMP until this is available https://github.com/surface-ui/surface/pull/755
    reloadable_compilers: [:leex, :elixir],
    # reloadable_compilers: [:leex, :elixir, :surface],
    reloadable_apps: [:bonfire] ++ local_dep_names,
    live_reload: [
      patterns: patterns ++ hot_patterns,
      notify: [
        live_view: hot_patterns
      ],
      web_console_logger: false
    ],
    watchers: [
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
    ]
end

#  code reloading

config :bonfire, Bonfire.Web.Endpoint, phoenix_profiler: [server: Bonfire.Web.Profiler]

log_level = String.to_existing_atom(System.get_env("DEV_LOG_LEVEL", "debug"))

truncate =
  case System.get_env("DEV_LOG_TRUNCATE", "2000") do
    "0" -> :infinity
    truncate -> String.to_integer(truncate)
  end

config :logger,
  level: log_level,
  truncate: truncate

config :surface,
  log_level: log_level

config :logger, :console,
  truncate: truncate,
  # Do not include metadata or timestamps
  format: "[$level] $message\n"

config :phoenix, :stacktrace_depth, 60

config :phoenix, :plug_init_mode, :runtime

config :exsync,
  src_monitor: true,
  reload_timeout: 75,
  # addition_dirs: ["/forks"],
  extra_extensions: [".leex", ".heex", ".js", ".css", ".sface"]

config :versioce, :changelog,
# Important: indicate date of last release, to generate a changelog for issues closed since then
  closed_after: System.get_env("CHANGES_CLOSED_AFTER", "2024-01-01"),
  changelog_file: "docs/CHANGELOG-autogenerated.md",
  # datagrabber: Versioce.Changelog.DataGrabber.Git,
  datagrabber: Bonfire.Common.Changelog.Github.DataGrabber,
  formatter: Versioce.Changelog.Formatter.Keepachangelog,
  anchors: %{
        added: ["✨", "💡", "🎨", "👷", "✅", "🚧"],
        changed: ["🚀", "💅", "🎨", "📝", "🌏", "⚡"],
        deprecated: ["♻️"],
        removed: ["🔥", "⚰️"],
        fixed: ["🐛"],
        security: ["🚨", "🔒"]
  }


# config :source_inspector, :enabled, true
config :phoenix_live_view, debug_heex_annotations: true

config :live_view_native_stylesheet,
  annotations: true,
  pretty: true
