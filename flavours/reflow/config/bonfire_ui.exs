import Config


config :bonfire, :ui,
   theme: [
      instance_name: "Reflow Demo",
      instance_icon: "https://reflowproject.eu/wp-content/themes/reflow/images/logoWhite.svg",
      instance_image: "https://reflowproject.eu/wp-content/uploads/2020/06/reflow-blog-1600x900.jpg",
      instance_description: "This is a Reflow demo instance",
      instance_welcome: [
         links: [
            "About Bonfire": "https://bonfirenetworks.org/",
            "About Reflow": "https://reflowproject.eu/",
            "Contribute": "https://bonfirenetworks.org/contribute/"
         ]
      ]
   ],
   sidebar_components: [
      {Bonfire.UI.Common.SidebarNavigationLive, []},
      {Bonfire.UI.Reflow.SidebarNavigationLive, []},
      # {Bonfire.UI.ValueFlows.ProcessesListLive, [title: "Processes", process_url: "/process/"]},
   ],
   smart_input: [
      post: false,
      cw: true,
      summary: true
   ],
   rich_text_editor: Bonfire.Editor.Ck,
   default_smart_input: Bonfire.UI.ValueFlows.CreateProcessSmartInputLive,
   profile: [
      sections: [
         timeline: Bonfire.UI.Social.ProfileTimelineLive,
         private: Bonfire.UI.Social.MessageThreadsLive,
         posts: Bonfire.UI.Social.ProfilePostsLive,
         boosts: Bonfire.UI.Social.ProfileBoostsLive,
         followers: Bonfire.UI.Social.ProfileFollowsLive,
         followed: Bonfire.UI.Social.ProfileFollowsLive,
         inventory: Bonfire.UI.Reflow.ProfileInventoryLive,
      ],
      navigation: [
         timeline: "timeline",
         inventory: "inventory",
         # posts: "posts",
         # boosts: "boosts",
         # private: "private",
      ],
      widgets: [
      ],
   ],
   smart_input_activities: [
      # offer: "Publish an offer",
      # need: "Publish a need",
      transfer_resource: "Transfer a resource",
      produce_resource: "Add a resource",
      # intent: "Indicate an itent",
      # economic_event: "Record an economic event",
      process: "Create a process"
   ],
   smart_input_components: [
      post: Bonfire.UI.Social.WritePostContentLive,
      # economic_event: Bonfire.UI.ValueFlows.SelectEconomicEventLive,
      # intent: Bonfire.UI.ValueFlows.CreateIntentLive,
      # task: Bonfire.UI.Coordination.CreateTaskLive,
      process: Bonfire.UI.ValueFlows.CreateProcessSmartInputLive
   ],
   resource: [
      navigation: [
         trace: "trace",
         track: "track",
      ],
      widgets: [
         # Bonfire.UI.Social.SubscribeWidgetLive
         Bonfire.UI.ValueFlows.LocationWidgetLive,
         Bonfire.UI.ValueFlows.PrimaryAccountableWidgetLive,
      ],
   ],
   default_instance_feed_previews: [
      process: Bonfire.UI.Social.Activity.ProcessReflowLive
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
