import Config

config :bonfire_common,
  localisation_path: "priv/localisation"

config :bonfire_ui_common,
  otp_app: :bonfire_ui_common,
  default_web_namespace: Bonfire.UI.Common

config :phoenix, :json_library, Jason

# The icons the icon picker offers, in three lists (shown in this order). Read at compile time by `Bonfire.UI.Common.IconPickerLive`, which also builds the CSS of each icon then: after changing a list, recompile bonfire_ui_common.
config :bonfire_ui_common, Bonfire.UI.Common.IconPickerLive,
  # what a category of events can have as its icon: the ones the FEP-8a8e categories start with, then others that read well for a place, a cause, a subject or a mood. All Phosphor "fill", as the rest of the icons in use.
  category_icons: ~w(
    ph:music-notes-fill ph:palette-fill ph:fork-knife-fill ph:confetti-fill ph:users-three-fill
    ph:users-fill ph:megaphone-fill ph:soccer-ball-fill ph:graduation-cap-fill ph:flask-fill
    ph:film-slate-fill ph:mask-happy-fill ph:ticket-fill ph:game-controller-fill ph:handshake-fill
    ph:briefcase-fill ph:hand-heart-fill ph:leaf-fill ph:flower-lotus-fill ph:mountains-fill
    ph:baby-fill ph:translate-fill ph:rainbow-fill ph:hands-clapping-fill ph:scissors-fill
    ph:sparkle-fill ph:wrench-fill ph:hammer-fill ph:t-shirt-fill ph:camera-fill ph:books-fill
    ph:smiley-fill ph:paw-print-fill ph:yin-yang-fill ph:car-fill
  ),
  more_icons: ~w(
    ph:globe-fill ph:compass-fill ph:map-pin-fill ph:house-fill ph:acorn-fill ph:campfire-fill ph:planet-fill
    ph:rocket-launch-fill ph:microscope-fill
    ph:heart-fill ph:pulse-fill ph:timer-fill ph:hand-fill
    ph:chart-bar-fill ph:chart-line-fill ph:trend-up-fill ph:kanban-fill ph:target-fill ph:bookmark-fill
    ph:book-fill ph:newspaper-fill ph:quotes-fill
    ph:note-fill ph:paint-brush-fill ph:image-fill ph:rss-fill
    ph:users-four-fill ph:chats-circle-fill ph:calendar-blank-fill ph:clock-fill ph:flag-fill
    ph:shield-fill ph:shield-check-fill ph:seal-check-fill ph:siren-fill
    ph:hash-fill ph:at-fill ph:folder-fill ph:push-pin-fill
    ph:ghost-fill ph:fire-fill ph:smiley-wink-fill
  ),
  # more for a topic, group or label, by theme: nature and weather, food, places, arts and media, tech, society, identity and labels. The weight is as compiled, and the viewer's icon style setting remaps them where a variant exists.
  themed_icons: ~w(
    ph:cat-fill ph:moon ph:moon-stars ph:sun ph:sun-horizon ph:wind ph:drop ph:lightning
    ph:coffee-duotone ph:cooking-pot-bold ph:carrot-bold
    ph:buildings ph:globe-hemisphere-west
    ph:book-open ph:pen-nib ph:puzzle-piece ph:chats ph:images-duotone ph:video-duotone
    ph:broadcast-duotone ph:waveform-duotone
    ph:code ph:desktop ph:device-mobile ph:cpu-duotone ph:hard-drives ph:circles-three ph:lightbulb
    ph:scales-duotone ph:gift-duotone ph:hand-waving ph:heartbeat-duotone
    ph:identification-card-duotone ph:user-circle ph:tag-fill
  )

cwd = File.cwd!()

dep_path = Path.join([cwd, "extensions", "bonfire_ui_common"])

dep_path =
  if File.exists?(dep_path) do
    dep_path
  else
    dep_path = Path.join([cwd, "deps", "bonfire_ui_common"])

    if File.exists?(dep_path) do
      dep_path
    else
      cwd
    end
  end

config :bonfire, :ui,
  theme: [
    # instance_name: "Bonfire",
    # the theme mode: `:system` follows the device's light/dark preference, switching between `instance_theme_light` and `instance_theme` (so keep both set), or `:light`, `:dark` or `:custom`
    preferred: :system,
    # the dark theme
    instance_theme: "dark",
    instance_theme_light: "light",
    instance_icon: "/images/bonfire-icon.png",
    instance_image: "/images/bonfires.png",
    # show the banner in the top left corner instead of the icon
    banner_as_icon: false,
    instance_tagline: "Yet another federated digital space",
    instance_description: "This is a bonfire demo instance for testing purposes",
    instance_welcome: [
      description:
        "Powered by [Bonfire](https://bonfirenetworks.org), a federated social networking toolkit to customise and host your own online space and control your experience at the most granular level.",
      links: [
        "About Bonfire": "https://bonfirenetworks.org/",
        Forum: "https://socialhub.activitypub.rocks/g/bonfire/activity/posts",
        "Community Chat": "https://matrix.to/#/%23bonfire-networks:matrix.org",
        Contribute: "https://bonfirenetworks.org/contribute/"
      ]
    ]
  ],
  terms: [
    conduct: "https://raw.githubusercontent.com/bonfire-networks/blog/master/code_of_conduct.md"
  ],
  # Email palette for transactional emails (signup confirm, password reset,
  # login link). Email clients don't support DaisyUI CSS vars, so values
  # are concrete colors. Flavours and instance admins can override.
  auth: [
    email_theme: [
      primary: "#e63946",
      primary_content: "#ffffff",
      body_bg: "#fff7f7",
      body_text: "#1f1f1f",
      muted: "#6b6b6b"
    ]
  ],
  show_activity_counts: false,
  show_profile_background_image: true,
  # should be enabled if using any extra extensions (other than social) or if you used some in the past and still want to display the old activities
  # TODO: check if / how much this slows down the app
  feed_object_extension_preloads_disabled: false,
  # end theme
  hide_app_switcher: true,
  rich_text_editor_disabled: false,
  # rich_text_editor: Bonfire.Editor.Quill,
  # rich_text_editor: Bonfire.Editor.Ck,
  rich_text_editor: Bonfire.Editor.Milkdown,
  # rich_text_editor: Bonfire.Editor.TiptapLive,
  # rich_text_editor: Bonfire.UI.Common.ComposerLive,
  # default
  font_family: "Inter (Latin Languages)",
  font_families: [
    "Inter (Latin Languages)",
    "Inter (More Languages)",
    "Noto Sans (Latin Languages)",
    "Noto Sans (More Languages)",
    "Luciole",
    "OpenDyslexic"
  ],
  themes_dark: ["dark"],
  themes_light: ["light"],
  # Lumis theme used for code blocks in each Bonfire theme, see https://lumis.sh and `Bonfire.UI.Common.CodeTheme`
  code_themes: %{"light" => "bamboo_light", "dark" => "bamboo_vulgaris"},
  show_trending_tags: [
    disabled: false,
    for_last_x_days: 30,
    limit: 8
  ],
  smart_input: [
    post: true,
    cw: true,
    title: true,
    summary: true
  ],
  # smart_input_activities: [
  #   post: "Compose a post",
  #   category: "Create a topic",
  #   label: "New label"
  # ],
  # smart_input_components: [ # NOTE: replaced by the SmartInputModule behaviour
  #   post: Bonfire.UI.Social.WritePostContentLive,
  #   message: Bonfire.UI.Social.WritePostContentLive,
  #   category: Bonfire.Classify.Web.NewCategoryLive,
  #   label: Bonfire.Label.Web.NewLabelLive,
  #   page: Bonfire.Pages.Web.CreatePageLive,
  #   section: Bonfire.Pages.Web.EditSectionLive
  # ],
  smart_input_as: :non_blocking

# verb families moved to `bonfire_social`, alongside the kinds they group

config :bonfire_ui_common, Bonfire.UI.Common.SmartInputLive,
  max_length: 2000,
  max_uploads: 4

config :surface_catalogue,
  title: "Bonfire UI",
  subtitle: "Surface Components Documentation & Examples"

config :iconify_ex,
  env: config_env(),
  generated_icon_app: :bonfire_ui_common,
  mode: :css,
  using_svg_inject: false,
  generated_icon_modules_path: "#{dep_path}/lib/components/icons",
  generated_icon_static_url: "/images/icons",
  generated_icon_static_path: "#{dep_path}/assets/static/images/icons",
  # alternative phosphor weights the icon style setting can switch to
  # (each generates an icons-<weight>.css alongside icons.css)
  weight_variants: %{"ph" => ["fill", "duotone", "light"]}

config :surface, :components, [
  {Bonfire.UI.Common.Modular.StatelessComponent, propagate_context_to_slots: true},
  {Bonfire.UI.Common.Modular.StatefulComponent, propagate_context_to_slots: true},
  {Iconify.Icon, propagate_context_to_slots: false},
  {Bonfire.UI.Common.ReusableModalLive, propagate_context_to_slots: true},
  {Bonfire.UI.Common.LinkLive, propagate_context_to_slots: true},
  {Bonfire.UI.Common.LogoLinkLive, propagate_context_to_slots: false},
  {Bonfire.UI.Social.Activity.LinkToActivityLive, propagate_context_to_slots: true},
  {Bonfire.UI.Common.TabsLive, propagate_context_to_slots: true},
  {Bonfire.UI.Social.FeedLive, propagate_context_to_slots: true}
]

# variants_prefix: "s-"

# read by `CORSPlug.init/1` as defaults, under the options the endpoint passes (`plug CORSPlug, origin: …, headers: ["*"]` in `Bonfire.UI.Common.EndpointTemplate`), so only the keys the endpoint doesn't pass take effect
config :cors_plug,
  # default: "*" # NOTE: we set specific origins per route in Bonfire.UI.Common.RuntimeConfig
  # origin: [],
  # ^ commented out: the endpoint passes `origin:` itself, which overrides this
  # default: 1_728_000
  max_age: 86_400,
  # same as default
  methods: ["POST", "PUT", "DELETE", "GET", "PATCH", "OPTIONS"],
  # default: []
  expose: [
    "Link",
    "X-RateLimit-Reset",
    "X-RateLimit-Limit",
    "X-RateLimit-Remaining",
    "X-Request-Id",
    "Idempotency-Key"
  ]

# send_preflight_response?: true # default: true
# credentials: true, # default: true
# headers: ["Authorization", "Content-Type", "Idempotency-Key"]
# ^ commented out: the endpoint passes `headers: ["*"]` itself, which overrides this

# default headers: [
#   "Authorization",
#   "Content-Type",
#   "Accept",
#   "Origin",
#   "User-Agent",
#   "DNT",
#   "Cache-Control",
#   "X-Mx-ReqToken",
#   "Keep-Alive",
#   "X-Requested-With",
#   "If-Modified-Since",
#   "X-CSRF-Token"
# ],
