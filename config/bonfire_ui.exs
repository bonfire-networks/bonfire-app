import Config

config :bonfire, :ui,
   sidebar_components: [
      Bonfire.UI.Social.SidebarNavigationLive,
      Bonfire.UI.Reflow.SidebarNavigationLive
   ],
   profile_navigation: [
      timeline: "timeline",
      posts: "posts",
      boosts: "boosts",
      inventory: "inventory"
   ],
   profile_sections: [
      private: Bonfire.UI.Social.PrivateLive,
      timeline: Bonfire.UI.Social.ProfileTimelineLive,
      posts: Bonfire.UI.Social.ProfilePostsLive,
      boosts: Bonfire.UI.Social.ProfileBoostsLive,
      followers: Bonfire.UI.Social.ProfileFollowersLive,
      followed: Bonfire.UI.Social.ProfileFollowersLive,
      inventory: Bonfire.UI.Reflow.ProfileInventoryLive,
   ]
