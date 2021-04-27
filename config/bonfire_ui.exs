import Config

config :bonfire, :ui,
   sidebar_components: [
      Bonfire.UI.Social.SidebarNavigationLive,
      Bonfire.UI.Reflow.SidebarNavigationLive
   ],
   profile_sections: [
      timeline: Bonfire.UI.Social.ProfileTimelineLive,
      private: Bonfire.UI.Social.PrivateLive,
      posts: Bonfire.UI.Social.ProfilePostsLive,
      boosts: Bonfire.UI.Social.ProfileBoostsLive,
      followers: Bonfire.UI.Social.ProfileFollowersLive,
      followed: Bonfire.UI.Social.ProfileFollowersLive,
      inventory: Bonfire.UI.Reflow.ProfileInventoryLive,
   ],
   profile_navigation: [
      timeline: "timeline",
      inventory: "inventory",
   ],
   profile_widgets: [
      Bonfire.UI.Social.SearchWidgetLive
   ],
   resource_navigation: [
      timeline: "timeline",
      material_passport: "material passport",
   ],
   resource_widgets: [
      Bonfire.UI.Social.SearchWidgetLive,
     # Bonfire.UI.Social.SubscribeWidgetLive,
      Bonfire.UI.ValueFlows.LocationWidgetLive,
      Bonfire.UI.Social.HashtagsWidgetLive,
   ],
   process_navigation: [
      events: "Economic events",
      intents: "Intents",
      # material_passport: "material passport",
   ],
   process_sections: [
      events: Bonfire.UI.ValueFlows.EconomicEventsLive,
      intents: Bonfire.UI.ValueFlows.IntentsLive,
   ],
   process_widgets: [
      Bonfire.UI.Social.SearchWidgetLive,
     # Bonfire.UI.Social.SubscribeWidgetLive,
     # Bonfire.UI.ValueFlows.LocationWidgetLive,
     # Bonfire.UI.Social.HashtagsWidgetLive,
   ],
   smart_input: [
      post: true,
      cw: true,
      summary: true
   ],
   smart_input_activities: [
      #offer: "Publish an offer",
      # need: "Publish a need",
      transfer_resource: "Transfer a resource",
      produce_resource: "Add a resource",
      process: "Create a process"
   ],
   smart_input_forms: [
      post: Bonfire.UI.Social.CreateActivityLive,
      #offer: Bonfire.UI.ValueFlows.CreateOfferWidgetLive
      # need:
      transfer_resource: Bonfire.UI.ValueFlows.CreateOfferWidgetLive,
      produce_resource: Bonfire.UI.ValueFlows.CreateOfferWidgetLive,
      process: Bonfire.UI.ValueFlows.CreateOfferWidgetLive
   ]
