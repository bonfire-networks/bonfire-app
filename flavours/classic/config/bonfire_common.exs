import Config

default_locale = "en"

config :bonfire_common,
  otp_app: :bonfire

# internationalisation
config :bonfire_common, Bonfire.Common.Localise.Cldr,
  default_locale: default_locale,
  locales: [default_locale, "es"], # locales that will be made available on top of those for which gettext localisation files are found
  providers: [Cldr.Language],
  gettext: Bonfire.Common.Localise.Gettext,
  extra_gettext: [Timex.Gettext], # extra Gettex modules from dependencies not using the one from Bonfire.Common, so we can change their locale too
  data_dir: "./priv/cldr",
  add_fallback_locales: true,
  # precompile_number_formats: ["¤¤#,##0.##"],
  # precompile_transliterations: [{:latn, :arab}, {:thai, :latn}]
  # force_locale_download: false,
  generate_docs: true
