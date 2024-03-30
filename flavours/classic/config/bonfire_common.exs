import Config

default_locale = "en"

config :bonfire_common,
  otp_app: :bonfire

# internationalisation
config :bonfire_common, Bonfire.Common.Localise.Cldr,
  default_locale: default_locale,
  # locales that will be made available on top of those for which gettext localisation files are available
  locales: ["fr", "en", "es"],
  providers: [
    Cldr.Language,
    Cldr.DateTime,
    Cldr.Number,
    Cldr.Unit,
    Cldr.List,
    Cldr.Calendar,
    Cldr.Territory,
    Cldr.LocaleDisplay
  ],
  gettext: Bonfire.Common.Localise.Gettext,
  data_dir: "./priv/cldr",
  add_fallback_locales: true,
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
