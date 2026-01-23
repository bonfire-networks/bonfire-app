import Config

yes? = ~w(true yes 1)
no? = ~w(false no 0)

default_locale = "en"

## Localisation & internationalisation
# Only compile additional locales in prod or when explicitly requested
compile_all_locales? = (System.get_env("COMPILE_ALL_LOCALES") not in no? and config_env() == :prod) or System.get_env("COMPILE_ALL_LOCALES") in yes?

locales = if compile_all_locales?, do: [default_locale, "fr", "es", "it"], else: [default_locale]

config :bonfire_common,
  otp_app: :bonfire,
  localisation_path: "priv/localisation",
  ecto_repos: [Bonfire.Common.Repo]

# internationalisation
config :bonfire_common, Bonfire.Common.Localise.Cldr,
  default_locale: default_locale,
  # locales that will be made available on top of those for which gettext localisation files are available
  locales: locales,
  providers: [
    Cldr.Language,
    Cldr.DateTime,
    Cldr.Number,
    Cldr.Unit,
    Cldr.List,
    Cldr.Calendar,
    Cldr.Territory,
    Cldr.LocaleDisplay,
    Cldr.Trans
  ],
  gettext: Bonfire.Common.Localise.Gettext,
  extra_gettext: [Timex.Gettext],
  data_dir: "./priv/cldr",
  add_fallback_locales: compile_all_locales?,
  # precompile_number_formats: ["¤¤#,##0.##"],
  # precompile_transliterations: [{:latn, :arab}, {:thai, :latn}]
  force_locale_download: Mix.env() == :prod,
  generate_docs: true

config :ex_cldr_units,
  default_backend: Bonfire.Common.Localise.Cldr

config :ex_cldr,
  default_locale: default_locale,
  default_backend: Bonfire.Common.Localise.Cldr,
  json_library: Jason

pg_username = System.get_env("POSTGRES_USER") || "postgres"
pg_pw = System.get_env("POSTGRES_PASSWORD") || "postgres"
database = System.get_env("POSTGRES_DB") || "bonfire_dev"
pg_host =        System.get_env("POSTGRES_HOST") || "localhost"

config :bonfire_common, Bonfire.Common.Repo,
  database: database,
  username: pg_username,
  password: pg_pw,
  hostname: pg_host,
  # show_sensitive_data_on_connection_error: true,
  # EctoSparkles does the logging instead
  log: false,
  stacktrace: true

config :sql, pools: [
  default: %{
    username: pg_username,
    password: pg_pw,
    hostname: pg_host,
    database: database,
    adapter: SQL.Adapters.Postgres,
    repo: Bonfire.Common.Repo,
    ssl: false}
  ]

config :rustler_precompiled, force_build_all: System.get_env("RUSTLER_BUILD_ALL") in ["true", "1"]

