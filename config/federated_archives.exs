import Config

#### Extension-specific compile-time configuration goes here, everything else should be in `FederatedArchives.RuntimeConfig`

# Please note that most of these are defaults meant to be overridden by instance admins in Settings rather than edited here
config :bonfire, :ui,
  theme: [
    instance_name: "Federated Archives",
    instance_theme: "bonfire",
    instance_theme_light: "light",
    instance_icon: "/images/bonfire-icon.png",
    instance_image: "/images/bonfires.png",
    instance_description:
      "Your federated archives instance for preserving and sharing knowledge.",
    instance_welcome: [
      title: "👋 Welcome to Federated Archives",
      description:
        "This is a space for archiving, preserving, and sharing knowledge across the fediverse. Join our community to contribute and explore archived content.",
      links: [
        "About Archives": "https://example.org/about",
        Documentation: "https://example.org/docs",
        Contribute: "https://example.org/contribute"
      ]
    ]
  ],
  # end theme
  hide_app_switcher: false,
  feed_object_extension_preloads_disabled: false,
  profile: [
    # TODO: make dynamic based on active extensions
    sections: [
      # inventory: Bonfire.UI.Reflow.ProfileInventoryLive,
    ],
    navigation: [
      # inventory: "inventory",
    ],
    widgets: []
  ],
  # smart_input_activities: [
  #   category: "Create a topic",
  #   label: "New label",
  #   task: "Add a task",
  #   offer: "Publish an offer",
  #   need: "Publish a need",
  #   # transfer_resource: "Transfer a resource",
  #   # produce_resource: "Add a resource",
  #   # intent: "Indicate an itent",
  #   economic_event: "Record an economic event",
  #   process: "Define a process"
  # ],
  # smart_input_components: [ # NOTE: replaced by the SmartInputModule behaviour
  #   task: Bonfire.UI.FederatedArchives.CreateTaskLive,
  #   upcycle_intent: Bonfire.Upcycle.Web.CreateIntentLive,
  #   upcycle_resource: Bonfire.Upcycle.Web.CreateResourceLive,
  #   upcycle_transfer: Bonfire.Upcycle.Web.CreateTransferLive,
  #   economic_event: Bonfire.UI.ValueFlows.SelectEconomicEventLive,
  #   process: Bonfire.UI.ValueFlows.CreateProcessLive,
  #   offer: Bonfire.UI.ValueFlows.CreateIntentLive,
  #   need: Bonfire.UI.ValueFlows.CreateIntentLive
  # ],
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

config :bonfire_data_shared_user, modularity: :disabled
config :bonfire_me, Bonfire.Me.SharedUsers, modularity: :disabled

config :bonfire_me, Bonfire.Me.Users, max_per_account: 1
