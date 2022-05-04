import Config

default_locale = "en"

config :bonfire_common,
  otp_app: :bonfire

# internationalisation
config :bonfire_common, Bonfire.Common.Localise.Cldr,
  default_locale: default_locale,
  locales: ["fr", "en", "es"], # locales that will be made available on top of those for which gettext localisation files are available
  providers: [Cldr.Language],
  gettext: Bonfire.Common.Localise.Gettext,
  data_dir: "./priv/cldr",
  add_fallback_locales: true,
  # precompile_number_formats: ["¤¤#,##0.##"],
  # precompile_transliterations: [{:latn, :arab}, {:thai, :latn}]
  # force_locale_download: false,
  generate_docs: true
