import Config

config :bonfire, :ui,
  theme: [
    instance_name: "Upcycle",
    instance_icon: "/images/bonfire-icon.png",
    instance_image: "https://bonfirenetworks.org/img/brand2.png",
    instance_description: "This is a bonfire demo instance (upcycle flavour) for testing purposes"
  ],
  feed_object_extension_preloads_disabled: false,
  # smart_input_components: [ # NOTE: replaced by the SmartInputModule behaviour
  #   economic_event: Bonfire.UI.ValueFlows.SelectEconomicEventLive,
  #   intent: Bonfire.UI.ValueFlows.CreateIntentLive,
  #   process: Bonfire.UI.ValueFlows.SelectEconomicEventLive
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
