import Config


config :bonfire, :ui,
   theme: [
      instance_name: "Bonfire",
      instance_logo: "https://bonfirenetworks.org/img/bonfire.png",
      instance_image: "https://bonfirenetworks.org/img/brand2.png",
      instance_description: "This is a bonfire demo instance for testing purposes"
   ],
   app_menu_extension_paths: %{ # TODO: make dynamic based on active extensions
      "Social" => Bonfire.Social.Web.HomeLive,
      "Breadpub" => Bonfire.Breadpub.Web.HomeLive,
      "Kanban" => Bonfire.UI.Kanban.HomeLive,
      # "Coordination" => Bonfire.UI.Coordination.ProcessesLive
   },
   sidebar_components: [ # TODO: make dynamic based on active extensions
      {Bonfire.UI.Social.SidebarNavigationLive, []},
      # {Bonfire.UI.Coordination.SidebarNavigationLive, []},
      #{Bonfire.Breadpub.SidebarNavigationLive, []},
      # {Bonfire.UI.ValueFlows.ProcessesListLive, [title: "Processes", process_url: "/process/"]},
      # {Bonfire.UI.ValueFlows.ProcessesListLive, [title: "Lists", process_url: "/breadpub/list/"]}
   ],
   smart_input: [
      post: true,
      cw: true,
      summary: true
   ],
   profile: [
      sections: [ # TODO: make dynamic based on active extensions
         timeline: Bonfire.UI.Social.ProfileTimelineLive,
         private: Bonfire.UI.Social.PrivateLive,
         posts: Bonfire.UI.Social.ProfilePostsLive,
         boosts: Bonfire.UI.Social.ProfileBoostsLive,
         followers: Bonfire.UI.Social.ProfileFollowsLive,
         followed: Bonfire.UI.Social.ProfileFollowsLive,
         # inventory: Bonfire.UI.Reflow.ProfileInventoryLive,
      ],
      navigation: [
         timeline: "timeline",
         # inventory: "inventory",
         posts: "posts",
         boosts: "boosts",
         # private: "private",
      ],
      widgets: [
      ],
   ],
   smart_input_activities: [
      # offer: "Publish an offer",
      # need: "Publish a need",
      # transfer_resource: "Transfer a resource",
      # produce_resource: "Add a resource",
      # intent: "Indicate an itent",
      # economic_event: "Record an economic event",
      # process: "Define a process"
   ],
   smart_input_forms: [
      post: Bonfire.UI.Social.CreateActivityLive,
      economic_event: Bonfire.UI.ValueFlows.SelectEconomicEventLive,
      intent: Bonfire.UI.ValueFlows.CreateIntentLive,
      process: Bonfire.UI.ValueFlows.CreateProcessLive,
   ],
   resource: [
      navigation: [
         timeline: "timeline",
         material_passport: "material passport",
      ],
      widgets: [
        # Bonfire.UI.Social.SubscribeWidgetLive,
         Bonfire.UI.ValueFlows.LocationWidgetLive,
         Bonfire.UI.Social.HashtagsWidgetLive,
      ],
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
