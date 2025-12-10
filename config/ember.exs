import Config

#### Flavour-specific compile-time configuration goes here, everything else should be in `Ember.RuntimeConfig`

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

compile_all_locales? =
  config_env() == :prod or System.get_env("COMPILE_ALL_LOCALES") in ["true", "1"]

locales = if compile_all_locales?, do: [
  "af", # Afrikaans
  "ar", # Arabic
  "az", # Azerbaijani
  "be", # Belarusian
  "bg", # Bulgarian
  "bn", # Bengali
  "bo", # Tibetan
  "bs", # Bosnian
  "br", # Breton
  "ca", # Catalan
  "ce", # Chechen
  "chr", # Cherokee
  "co", # Corsican
  "cs", # Czech
  "ckb", # Central Kurdish
  "ku", # Kurdish / Kurmanji
  "sdh", # Southern Kurdish
  "da", # Danish
  "de", # German
  "de-CH", # German (Switzerland)
  "dz", # Dzongkha
  "el", # Greek
  "en", # English
  "en-US", # English (United States)
  "en-GB", # English (United Kingdom)
  "en-CA", # English (Canada)
  "en-SE", # English (Sweden)
  "eo", # Esperanto
  "es", # Spanish
  "es-AR", # Spanish (Argentina)
  "es-MX", # Spanish (Mexico)
  "es-ES", # Spanish (Spain)
  "et", # Estonian
  "eu", # Basque
  "fa", # Persian
  "fi", # Finnish
  "fil", # Filipino
  "fr", # French
  "fr-FR", # French (France)
  "fr-CA", # French (Canada)
  "fr-CH", # French (Switzerland)
  "ga", # Irish
  "gd", # Scottish Gaelic
  "gl", # Galician
  "gsw", # Swiss German
  "ha", # Hausa
  "he", # Hebrew
  "hi", # Hindi
  "hr", # Croatian
  "hu", # Hungarian
  "ht", # Haitian Creole
  "hy", # Armenian
  "id", # Indonesian
  "is", # Icelandic
  "it", # Italian
  "it-IT", # Italian (Italy)
  "it-CH", # Italian (Switzerland)
  "iu", # Inuktitut
  "ja", # Japanese
  "jv", # Javanese
  "ka", # Georgian
  "kk", # Kazakh
  "kl", # Greenlandic
  "km", # Khmer
  "kn", # Kannada
  "ko", # Korean
  "lb", # Luxembourgish
  "lo", # Lao
  "lt", # Lithuanian
  "lv", # Latvian
  "mg", # Malagasy
  "mi", # Maori
  "mk", # Macedonian
  "ml", # Malayalam
  "mn", # Mongolian
  "ms", # Malay
  "mt", # Maltese
  "my", # Burmese
  "nb", # Norwegian (Bokmål)
  "ne", # Nepali
  "nl", # Dutch
  "nn", # Norwegian (Nynorsk)
  "no", # Norwegian
  "oc", # Occitan
  "pa", # Panjabi (Punjabi)
  "pl", # Polish
  "ps", # Pashto
  "pt", # Portuguese
  "pt-BR", # Portuguese (Brazil)
  "pt-PT", # Portuguese (Portugal)
  "qu", # Quechua
  "rm", # Romansh
  "ro", # Romanian
  "ru", # Russian
  "sc", # Sardinian
  "scn", # Sicilian
  "sk", # Slovak
  "sl", # Slovenian
  # "sm", # Samoan
  "so", # Somali
  "sq", # Albanian
  "sr", # Serbian
  "st", # Sotho
  "su", # Sundanese
  "sv", # Swedish
  "sw", # Swahili
  "ta", # Tamil
  "te", # Telugu
  "ti", # Tigrinya
  "tg", # Tajik
  "th", # Thai
  "tk", # Turkmen
  # "tl", # Tagalog (see also Filipino)
  "to", # Tongan
  "tr", # Turkish
  "ts", # Tsonga
  "uk", # Ukrainian
  "ug", # Uyghur
  "ur", # Urdu
  "uz", # Uzbek
  "vi", # Vietnamese
  "wo", # Wolof
  "xh", # Xhosa
  "yi", # Yiddish
  "yo", # Yoruba
  "yue", # Cantonese
  "zh", # Chinese
  "zh-Hant", # Traditional Chinese
  "zh-Hant-HK", # Chinese (Hong Kong)
  "zh-Hant-TW", # Chinese (Taiwan)
  "zh-Hans", # Simplified Chinese
  "zh-Hans-SG", # Chinese (Singapore)
  "zu" # Zulu
], else: ["en", "fr", "es", "it"]

config :bonfire_common, Bonfire.Common.Localise.Cldr, locales: locales

