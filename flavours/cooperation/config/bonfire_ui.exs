import Config

config :bonfire, :ui,
  theme: [
    instance_name: "Bonfire",
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
        "About ValueFlows": "https://valueflo.ws/",
        Forum: "https://socialhub.activitypub.rocks/g/bonfire/activity/posts",
        "Community Chat": "https://matrix.to/#/%23bonfire-networks:matrix.org",
        Contribute: "https://bonfirenetworks.org/contribute/"
      ]
    ]
  ],

  # end theme
  # rich_text_editor_disabled: true,
  # rich_text_editor: Bonfire.Editor.Quill,
  rich_text_editor: Bonfire.Editor.Ck,
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
  profile: [
    # TODO: make dynamic based on active extensions
    sections: [
      timeline: Bonfire.UI.Social.ProfileTimelineLive,
      # private: Bonfire.UI.Social.MessageThreadsLive,
      posts: Bonfire.UI.Social.ProfilePostsLive,
      boosts: Bonfire.UI.Social.ProfileBoostsLive,
      followers: Bonfire.UI.Social.ProfileFollowsLive,
      followed: Bonfire.UI.Social.ProfileFollowsLive,
      follow: Bonfire.UI.Me.RemoteInteractionFormLive
      # inventory: Bonfire.UI.Reflow.ProfileInventoryLive,
    ],
    navigation: [
      timeline: "timeline",
      # inventory: "inventory",
      posts: "posts",
      boosts: "boosts"
      # private: "private",
    ],
    widgets: []
  ],
  smart_input_activities: [
    post: "Compose a post",
    label: "New label",
    task: "Add a task",
    offer: "Publish an offer",
    need: "Publish a need",
    # transfer_resource: "Transfer a resource",
    # produce_resource: "Add a resource",
    # intent: "Indicate an itent",
    economic_event: "Record an economic event",
    process: "Define a process"
  ],
  smart_input_components: [
    post: Bonfire.UI.Social.WritePostContentLive,
    message: Bonfire.UI.Social.WritePostContentLive,
    category: Bonfire.Classify.Web.NewCategoryLive,
    # label: Bonfire.UI.Coordination.CreateLabelLive,
    label: Bonfire.Classify.Web.NewLabelLive,
    task: Bonfire.UI.Coordination.CreateTaskLive,
    upcycle_intent: Bonfire.Upcycle.Web.CreateIntentLive,
    upcycle_resource: Bonfire.Upcycle.Web.CreateResourceLive,
    upcycle_transfer: Bonfire.Upcycle.Web.CreateTransferLive,
    economic_event: Bonfire.UI.ValueFlows.SelectEconomicEventLive,
    process: Bonfire.UI.ValueFlows.CreateProcessLive,
    offer: Bonfire.UI.ValueFlows.CreateIntentLive,
    need: Bonfire.UI.ValueFlows.CreateIntentLive,
    page: Bonfire.Pages.Web.CreatePageLive,
    section: Bonfire.Pages.Web.EditSectionLive
  ],
  resource: [
    navigation: [
      timeline: "timeline",
      material_passport: "material passport"
    ],
    widgets: [
      # Bonfire.UI.Social.SubscribeWidgetLive,
      Bonfire.UI.ValueFlows.LocationWidgetLive,
      Bonfire.UI.Social.HashtagsWidgetLive
    ]
  ]

# process: [
#    navigation: [
#       events: "Economic events",
#       intents: "Intents",
#       # material_passport: "material passport",
#    ],
#    sections: [
#       events: Bonfire.UI.ValueFlows.EconomicEventsLive,
#       intents: Bonfire.UI.ValueFlows.IntentsLive,
#    ],
#    widgets: [
#      # Bonfire.UI.Social.SubscribeWidgetLive,
#      # Bonfire.UI.ValueFlows.LocationWidgetLive,
#      # Bonfire.UI.Social.HashtagsWidgetLive,
#    ],
# ]

config :surface_catalogue,
  title: "Bonfire UI",
  subtitle: "Surface Components Documentation & Examples"
