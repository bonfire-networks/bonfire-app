import Config

#### Extension-specific compile-time configuration goes here, everything else should be in `Jacobin.RuntimeConfig`

# Please note that most of these are defaults meant to be overridden by instance admins in Settings rather than edited here
config :bonfire, :ui,
  # Make the Jacobin themes the instance default look (deep-merged into the
  # `theme:` keyword from bonfire_ui_common.exs, so instance_icon/tagline/etc.
  # are preserved). Admins can still override per-instance in Settings.
  theme: [
    instance_theme_light: "jacobin",
    instance_theme: "jacobin",
    # "powered by" credit in the footer
    powered_by: [name: "Jacobin.social + Bonfire", url: "https://jacobin.de/social"]
  ],
  hide_app_switcher: true,
  auth: [
    email_signature: "Deine Jacobin-Redaktion",
    email_theme: [
      primary: "#e63027",
      primary_content: "#ffffff",
      body_bg: "#fbf3e9",
      body_text: "#0a0a0a",
      muted: "#5c5c5c"
    ]
  ],
  font_family: "Lateral",
  font_families: [
    "Lateral",
    "Inter (Latin Languages)",
    "Inter (More Languages)",
    "Noto Sans (Latin Languages)",
    "Noto Sans (More Languages)",
    "Luciole",
    "OpenDyslexic"
  ],
  feed_object_extension_preloads_disabled: false,
  smart_input_activities: [
    category: "Create a topic",
    label: "New label"
  ],
  themes_light: [
    "jacobin",
    "light"
  ],
  themes_dark: [
    "dark"
  ]

# Transactional email copy. Any line left out here keeps `bonfire_me`'s own default, which is translated per recipient; anything set here is used as written, since `mix gettext.extract` can't see strings that live in config. Jacobin sends German, so the whole visible message is spelled out.
config :bonfire, Bonfire.Me.Mails,
  # Registration: signups come from subscriptions, so the generic
  # "confirm your email" wording is replaced by a subscription welcome.
  confirm_email: [
    subject: "Dein Abo ist hiermit bestätigt",
    intro:
      "danke für dein Abonnement bei Jacobin. Damit unterstützt du unabhängigen kritischen Journalismus.",
    intro_2:
      "Unser System funktioniert passwortlos. Klicke einfach auf den folgenden Link, um Zugang zu Jacobin.social zu erhalten:",
    cta: "Zugang erhalten",
    disclaimer: "Wenn du dich nicht registriert hast, kannst du diese E-Mail einfach ignorieren.",
    signoff: "Bis bald!",
    signature: "Deine Jacobin-Redaktion",
    paste_hint: "Du kannst diese URL auch kopieren und in deinem Browser einfügen:"
  ],
  # Passwordless sign-in link
  login_link_email: [
    subject: "Dein Login-Link für Jacobin.social",
    intro: "klicke auf den folgenden Link, um dich bei Jacobin.social anzumelden:",
    cta: "Anmelden",
    disclaimer:
      "Aus Sicherheitsgründen läuft dieser Link nach 24 Stunden ab. Wenn du diese Anmeldung nicht angefordert hast, kannst du diese E-Mail einfach ignorieren.",
    signoff: "Bis bald!",
    signature: "Deine Jacobin-Redaktion",
    paste_hint: "Du kannst diese URL auch kopieren und in deinem Browser einfügen:"
  ]

config :bonfire_ui_common, Bonfire.UI.Common.AvatarLive,
  generated_avatar_paths: [
    "/images/avatars/new-profiles-02.jpg",
    "/images/avatars/new-profiles-20.jpg",
    "/images/avatars/new-red-profiles-05.jpg",
    "/images/avatars/new-red-profiles-12.jpg",
    "/images/avatars/new-red-profiles-21.jpg",
    "/images/avatars/profiles-01.jpg",
    "/images/avatars/profiles-03.jpg",
    "/images/avatars/profiles-04.jpg",
    "/images/avatars/profiles-09.jpg",
    "/images/avatars/profiles-10.jpg",
    "/images/avatars/profiles-11.jpg",
    "/images/avatars/profiles-14.jpg",
    "/images/avatars/profiles-16.jpg",
    "/images/avatars/profiles-17.jpg",
    "/images/avatars/profiles-19.jpg",
    "/images/avatars/profiles.jpg",
    "/images/avatars/red-profiles-06.jpg",
    "/images/avatars/red-profiles-07.jpg",
    "/images/avatars/red-profiles-15.jpg",
    "/images/avatars/red-profiles-18.jpg"
  ]

# config :bonfire_social, Bonfire.Social.Pins, modularity: true
# config :bonfire_ui_reactions, Bonfire.UI.Reactions.PinActionLive, modularity: true

# enable marking comment as answer?
config :bonfire_social, Bonfire.Social.Answers, modularity: :disabled

# TODO: replace placeholder copy and URL with the real ones
config :bonfire_ui_social, Bonfire.UI.Social.RestrictedContentLive,
  modularity: true,
  title: "This post is for members",
  message: "Upgrade your membership to read this post and everything else on Jacobin.",
  cta_label: "Upgrade",
  cta_url: "https://jacobin.de/abo"

# Getting-started checklist shown to new users in the sidebar widget.
# Each entry is a key from
# `Bonfire.UI.Social.WidgetGettingStartedLive.actions_registry/0`; the copy
# and completion detectors live there (in code) so they stay translatable.
# Instance-specific URLs are passed here. Manual completion (`Mark done`) is
# always available, so steps without an auto-detector still work.
config :bonfire_ui_social, Bonfire.UI.Social.WidgetGettingStartedLive,
  actions: [:profile, :first_post, :first_follow, :read_coc, :wishes],
  code_of_conduct_path: "/conduct",
  wishes_url: "https://heyform-mglx.srv1627781.hstgr.cloud/form/7JpSZJ6H"

# Ghost webhook verification needs the raw JSON body for HMAC. BodyReader
# wraps `ActivityPub.Web.Plugs.DigestPlug.read_body/2` (so AP digests keep
# working) and stashes the raw body on JSON requests.
config :bonfire_ui_common,
       :body_reader,
       {Bonfire.Ghost.BodyReader, :read_body, []}
