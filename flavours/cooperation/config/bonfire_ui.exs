import Config


config :bonfire, :ui,
   theme: [
      instance_name: "Bonfire",
      instance_icon: "/images/bonfire-icon.png",
      instance_image: "/images/bonfires.png",
      instance_description: "This is a bonfire demo instance for testing purposes",
      instance_welcome: [
         title: "👋 Welcome",
         description: "Bonfire is a federated social networking toolkit to customise and host your own online space and control your experience at the most granular level.

More details at https://bonfirenetworks.org",
         links: [
            "About Bonfire": "https://bonfirenetworks.org/",
            "About ValueFlows": "https://valueflo.ws/",
            "Forum": "https://socialhub.activitypub.rocks/g/bonfire/activity/posts",
            "Community Chat": "https://matrix.to/#/%23bonfire-networks:matrix.org",
            "Contribute": "https://bonfirenetworks.org/contribute/"
         ]
   ]],
   app_menu_extension_paths: %{ # TODO: make dynamic based on active extensions
      "Social" => Bonfire.UI.Social.HomeLive,
      "Breadpub" => Bonfire.Breadpub.Web.HomeLive,
      "Kanban" => Bonfire.UI.Kanban.HomeLive,
      # "Coordination" => Bonfire.UI.Coordination.ProcessesLive
   },
   sidebar_components: [ # TODO: make dynamic based on active extensions
      {Bonfire.UI.Common.SidebarNavigationLive, []},
      # {Bonfire.UI.Coordination.SidebarNavigationLive, []},
      #{Bonfire.Breadpub.SidebarNavigationLive, []},
      # {Bonfire.UI.ValueFlows.ProcessesListLive, [title: "Processes", process_url: "/process/"]},
      # {Bonfire.UI.ValueFlows.ProcessesListLive, [title: "Lists", process_url: "/breadpub/list/"]}
   ],
   rich_text_editor: Bonfire.Editor.Quill,
   smart_input: [
      post: true,
      cw: true,
      summary: true
   ],
   profile: [
      sections: [ # TODO: make dynamic based on active extensions
         timeline: Bonfire.UI.Social.ProfileTimelineLive,
         # private: Bonfire.UI.Social.MessageThreadsLive,
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
      post: "Compose a post",
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
      economic_event: Bonfire.UI.ValueFlows.SelectEconomicEventLive,
      process: Bonfire.UI.ValueFlows.CreateProcessSmartInputLive,
      offer: Bonfire.UI.ValueFlows.CreateIntentLive,
      need: Bonfire.UI.ValueFlows.CreateIntentLive,
      task: Bonfire.UI.Coordination.CreateTaskLive,
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
