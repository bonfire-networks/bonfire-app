import Config

config :bonfire, :ui,
  theme: [
    instance_name: "Reflow Demo",
    instance_icon: "https://reflowproject.eu/wp-content/themes/reflow/images/logoWhite.svg",
    instance_image:
      "https://reflowproject.eu/wp-content/uploads/2020/06/reflow-blog-1600x900.jpg",
    instance_description: "This is a Reflow demo instance",
    instance_welcome: [
      links: [
        "About Bonfire": "https://bonfirenetworks.org/",
        "About Reflow": "https://reflowproject.eu/",
        Contribute: "https://bonfirenetworks.org/contribute/"
      ]
    ]
  ],
  feed_object_extension_preloads_disabled: false,
  default_smart_input: Bonfire.UI.ValueFlows.SelectEconomicEventLive,
  profile: [
    sections: [
      inventory: Bonfire.UI.Reflow.ProfileInventoryLive
    ],
    navigation: [
      inventory: "inventory"
      # posts: "posts",
      # boosts: "boosts",
      # private: "private",
    ],
    widgets: []
  ],
  # smart_input_activities: [
  #   # offer: "Publish an offer",
  #   # need: "Publish a need",
  #   transfer_resource: "Transfer a resource",
  #   produce_resource: "Add a resource",
  #   # intent: "Indicate an itent",
  #   # economic_event: "Record an economic event",
  #   process: "Create a process"
  # ],
  # smart_input_components: [ # NOTE: replaced by the SmartInputModule behaviour
  #   # economic_event: Bonfire.UI.ValueFlows.SelectEconomicEventLive,
  #   # intent: Bonfire.UI.ValueFlows.CreateIntentLive,
  #   # task: Bonfire.UI.Coordination.CreateTaskLive,
  #   process: Bonfire.UI.ValueFlows.SelectEconomicEventLive
  # ],
  resource: [
    navigation: [
      trace: "trace",
      track: "track"
    ],
    widgets: [
      # Bonfire.UI.Social.SubscribeWidgetLive
      Bonfire.UI.ValueFlows.LocationWidgetLive,
      Bonfire.UI.ValueFlows.PrimaryAccountableWidgetLive
    ]
  ],
  # TODO: replace with :object_preview
  default_instance_feed_previews: [
    process: Bonfire.UI.Reflow.Preview.ProcessReflowLive
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
