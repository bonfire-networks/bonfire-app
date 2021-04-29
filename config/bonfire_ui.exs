import Config

config :bonfire, :ui,
   sidebar_components: [
      Bonfire.UI.Social.SidebarNavigationLive,
      Bonfire.UI.ValueFlows.ProcessesListLive
   ],
   smart_input: [
      post: true,
      cw: true,
      summary: true
   ],
   profile: [
      sections: [
         timeline: Bonfire.UI.Social.ProfileTimelineLive,
         private: Bonfire.UI.Social.PrivateLive,
         posts: Bonfire.UI.Social.ProfilePostsLive,
         boosts: Bonfire.UI.Social.ProfileBoostsLive,
         followers: Bonfire.UI.Social.ProfileFollowersLive,
         followed: Bonfire.UI.Social.ProfileFollowersLive,
         inventory: Bonfire.UI.Reflow.ProfileInventoryLive,
      ],
      navigation: [
         timeline: "timeline",
         inventory: "inventory",
      ],
      widgets: [
         Bonfire.UI.Social.SearchWidgetLive
      ],
   ]
   resource: [
      navigation: [
         timeline: "timeline",
         material_passport: "material passport",
      ],
      widgets: [
         Bonfire.UI.Social.SearchWidgetLive,
        # Bonfire.UI.Social.SubscribeWidgetLive,
         Bonfire.UI.ValueFlows.LocationWidgetLive,
         Bonfire.UI.Social.HashtagsWidgetLive,
      ],
   ],
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
   #       Bonfire.UI.Social.SearchWidgetLive,
   #      # Bonfire.UI.Social.SubscribeWidgetLive,
   #      # Bonfire.UI.ValueFlows.LocationWidgetLive,
   #      # Bonfire.UI.Social.HashtagsWidgetLive,
   #    ],
   # ]
