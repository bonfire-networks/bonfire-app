import Config

# Please note that most of these are defaults meant to be overridden/extended by:
# 1) flavour-specific config
# 2) instance admins in Settings

config :bonfire, :ui,
  theme: [
    # instance_name: "Bonfire",
    instance_theme: "bonfire",
    instance_theme_light: "light",
    instance_icon: "/images/bonfire-icon.png",
    instance_image: "/images/bonfires.png",
    instance_description: "This is a bonfire demo instance for testing purposes",
    instance_welcome: [
      title: "👋 Welcome",
      description:
        "Bonfire is a federated social networking toolkit to customise and host your own online space and control your experience at the most granular level.

More details at https://bonfirenetworks.org",
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
  show_activity_counts: false,
  show_profile_background_image: true,
  # should be enabled if using any extra extensions (other than social) or if you used some in the past and still want to display the old activities
  feed_object_extension_preloads_disabled: true,
  # end theme
  hide_app_switcher: true,
  # rich_text_editor_disabled: true,
  # rich_text_editor: Bonfire.Editor.Quill,
  # rich_text_editor: Bonfire.Editor.Ck,
  rich_text_editor: Bonfire.UI.Common.ComposerLive,
  # default
  font_family: "Inter (Latin Languages)",
  font_families: [
    "Inter (Latin Languages)",
    "Inter (More Languages)",
    "Noto Sans (Latin Languages)",
    "Noto Sans (More Languages)",
    "OpenDyslexic"
  ],
  themes: [
    "bonfire",
    "dark",
    "synthwave",
    "retro",
    "cyberpunk",
    "valentine",
    "halloween",
    "garden",
    "forest",
    "aqua",
    "black",
    "luxury",
    "dracula",
    "business",
    "night",
    "coffee"
  ],
  themes_light: [
    "light",
    "cupcake",
    "bumblebee",
    "emerald",
    "corporate",
    "retro",
    "cyberpunk",
    "valentine",
    "garden",
    "lofi",
    "pastel",
    "fantasy",
    "wireframe",
    "cmyk",
    "autumn",
    "acid",
    "lemonade",
    "winter"
  ],
  show_trending_tags: [
    disabled: false,
    for_last_x_days: 30,
    limit: 8
  ],
  smart_input: [
    post: true,
    cw: true,
    summary: true
  ],
  invites_component: Bonfire.Invite.Links.Web.InvitesLive,
  smart_input_activities: [
    post: "Compose a post",
    category: "Create a topic",
    label: "New label"
  ],
  smart_input_components: [
    post: Bonfire.UI.Social.WritePostContentLive,
    message: Bonfire.UI.Social.WritePostContentLive,
    category: Bonfire.Classify.Web.NewCategoryLive,
    label: Bonfire.Classify.Web.NewLabelLive,
    page: Bonfire.Pages.Web.CreatePageLive,
    section: Bonfire.Pages.Web.EditSectionLive
  ],
  smart_input_as: :non_blocking

config :bonfire,
  # used by ActivityLive - TODO: autogenerate?
  verb_families: [
    reply: ["Reply", "Respond"],
    create: ["Create", "Write"],
    react: ["Like", "Boost", "Flag", "Tag"],
    simple_action: ["Assign", "Label", "Schedule"]
  ]

config :bonfire_ui_common, Bonfire.UI.Common.SmartInputLive,
  max_length: 2000,
  max_uploads: 4

config :surface_catalogue,
  title: "Bonfire UI",
  subtitle: "Surface Components Documentation & Examples"

config :iconify_ex,
  generated_icon_app: :bonfire,
  generated_icon_modules_path: "./extensions/bonfire/lib/web/icons"

config :surface, :components, [
  {Bonfire.UI.Common.ReusableModalLive, propagate_context_to_slots: true}
]
