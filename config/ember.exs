import Config

#### Flavour-specific compile-time configuration goes here, everything else should be in `Ember.RuntimeConfig`

yes? = ~w(true yes 1)
no? = ~w(false no 0)

# enable marking comment as answer?
# config :bonfire_social, Bonfire.Social.Answers, modularity: :disabled

# enable content labelling?
# config :bonfire_label, modularity: :disabled
config :bonfire_label, Bonfire.Label.Web.ContentLabelLive, modularity: :disabled

# enable custom boundaries in composer's boundary selector?
# config :bonfire_ui_boundaries, Bonfire.UI.Boundaries.CustomizeBoundaryLive, modularity: :disabled
# enable preview resulting boundaries in composer's boundary selector?
config :bonfire_ui_boundaries, Bonfire.UI.Boundaries.PreviewBoundariesLive, modularity: :disabled

# enable thread locking?
config :bonfire_ui_boundaries, Bonfire.Boundaries.Locking.LiveHandler, modularity: :disabled

# config :bonfire_ui_reactions, Bonfire.UI.Reactions.BookmarksLive, modularity: :disabled
# config :bonfire_ui_reactions, Bonfire.UI.Reactions.BookmarkActionLive, modularity: :disabled

# enable pinning?
config :bonfire_social, Bonfire.Social.Pins, modularity: :disabled
config :bonfire_ui_reactions, Bonfire.UI.Reactions.PinActionLive, modularity: :disabled

# disable emoji reactions
config :bonfire_ui_reactions, Bonfire.UI.Reactions.EmojiReactionsLive, modularity: :disabled

config :bonfire, :ui,
  default_nav_extensions: [
    :bonfire,
    :bonfire_ui_common,
    :bonfire_ui_social,
    :bonfire_ui_reactions,
    :bonfire_ui_messages,
    :bonfire_open_science,
    :bonfire_files
    # :bonfire_ui_search
  ]

config :bonfire_valueflows_api_schema, modularity: :disabled

config :bonfire_notify, modularity: :disabled

compile_all_locales? = (System.get_env("COMPILE_ALL_LOCALES") not in no? and config_env() == :prod) or System.get_env("COMPILE_ALL_LOCALES") in yes?

locales =
  if compile_all_locales?,
    do: [
      # Afrikaans
      "af",
      # Arabic
      "ar",
      # Azerbaijani
      "az",
      # Belarusian
      "be",
      # Bulgarian
      "bg",
      # Bengali
      "bn",
      # Tibetan
      "bo",
      # Bosnian
      "bs",
      # Breton
      "br",
      # Catalan
      "ca",
      # Chechen
      "ce",
      # Cherokee
      "chr",
      # Corsican
      "co",
      # Czech
      "cs",
      # Central Kurdish
      "ckb",
      # Kurdish / Kurmanji
      "ku",
      # Southern Kurdish
      "sdh",
      # Danish
      "da",
      # German
      "de",
      # German (Switzerland)
      "de-CH",
      # Dzongkha
      "dz",
      # Greek
      "el",
      # English
      "en",
      # English (United States)
      "en-US",
      # English (United Kingdom)
      "en-GB",
      # English (Canada)
      "en-CA",
      # English (Sweden)
      "en-SE",
      # Esperanto
      "eo",
      # Spanish
      "es",
      # Spanish (Argentina)
      "es-AR",
      # Spanish (Mexico)
      "es-MX",
      # Spanish (Spain)
      "es-ES",
      # Estonian
      "et",
      # Basque
      "eu",
      # Persian
      "fa",
      # Finnish
      "fi",
      # Filipino
      "fil",
      # French
      "fr",
      # French (France)
      "fr-FR",
      # French (Canada)
      "fr-CA",
      # French (Switzerland)
      "fr-CH",
      # Irish
      "ga",
      # Scottish Gaelic
      "gd",
      # Galician
      "gl",
      # Swiss German
      "gsw",
      # Hausa
      "ha",
      # Hebrew
      "he",
      # Hindi
      "hi",
      # Croatian
      "hr",
      # Hungarian
      "hu",
      # Haitian Creole
      "ht",
      # Armenian
      "hy",
      # Indonesian
      "id",
      # Icelandic
      "is",
      # Italian
      "it",
      # Italian (Italy)
      "it-IT",
      # Italian (Switzerland)
      "it-CH",
      # Inuktitut
      "iu",
      # Japanese
      "ja",
      # Javanese
      "jv",
      # Georgian
      "ka",
      # Kazakh
      "kk",
      # Greenlandic
      "kl",
      # Khmer
      "km",
      # Kannada
      "kn",
      # Korean
      "ko",
      # Luxembourgish
      "lb",
      # Lao
      "lo",
      # Lithuanian
      "lt",
      # Latvian
      "lv",
      # Malagasy
      "mg",
      # Maori
      "mi",
      # Macedonian
      "mk",
      # Malayalam
      "ml",
      # Mongolian
      "mn",
      # Malay
      "ms",
      # Maltese
      "mt",
      # Burmese
      "my",
      # Norwegian (Bokmål)
      "nb",
      # Nepali
      "ne",
      # Dutch
      "nl",
      # Norwegian (Nynorsk)
      "nn",
      # Norwegian
      "no",
      # Occitan
      "oc",
      # Panjabi (Punjabi)
      "pa",
      # Polish
      "pl",
      # Pashto
      "ps",
      # Portuguese
      "pt",
      # "pt-BR", # Portuguese (Brazil)
      # Portuguese (Portugal)
      "pt-PT",
      # Quechua
      "qu",
      # Romansh
      "rm",
      # Romanian
      "ro",
      # Russian
      "ru",
      # Sardinian
      "sc",
      # Sicilian
      "scn",
      # Slovak
      "sk",
      # Slovenian
      "sl",
      # "sm", # Samoan
      # Somali
      "so",
      # Albanian
      "sq",
      # Serbian
      "sr",
      # Sotho
      "st",
      # Sundanese
      "su",
      # Swedish
      "sv",
      # Swahili
      "sw",
      # Tamil
      "ta",
      # Telugu
      "te",
      # Tigrinya
      "ti",
      # Tajik
      "tg",
      # Thai
      "th",
      # Turkmen
      "tk",
      # "tl", # Tagalog (see also Filipino)
      # Tongan
      "to",
      # Turkish
      "tr",
      # Tsonga
      "ts",
      # Ukrainian
      "uk",
      # Uyghur
      "ug",
      # Urdu
      "ur",
      # Uzbek
      "uz",
      # Vietnamese
      "vi",
      # Wolof
      "wo",
      # Xhosa
      "xh",
      # Yiddish
      "yi",
      # Yoruba
      "yo",
      # Cantonese
      "yue",
      # Chinese
      "zh",
      # Traditional Chinese
      "zh-Hant",
      # Chinese (Hong Kong)
      "zh-Hant-HK",
      # Chinese (Taiwan)
      "zh-Hant-TW",
      # Simplified Chinese
      "zh-Hans",
      # Chinese (Singapore)
      "zh-Hans-SG",
      # Zulu
      "zu"
    ],
    else: ["en", "fr", "es", "it"]

config :bonfire_common, Bonfire.Common.Localise.Cldr, locales: locales
