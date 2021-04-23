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
   ]
