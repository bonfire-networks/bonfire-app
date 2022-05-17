import Config


config :bonfire, :ui,
   theme: [
      instance_name: "HAHA Academy",
      instance_icon: "https://bonfirenetworks.org/img/bonfire.png",
      instance_image: "https://haha.academy/images/wheel.png",
      instance_description: "Community roadmaps for learning every branch of human knowledge"
   ],
   sidebar_components: [
      {Bonfire.UI.Common.SidebarNavigationLive, []},
   ],
   smart_input: [
      post: true,
      cw: true,
      summary: true
   ],
   profile: [
      sections: [
         timeline: Bonfire.UI.Me.ProfileTimelineLive,
         private: Bonfire.UI.Social.MessageThreadsLive,
         posts: Bonfire.UI.Me.ProfilePostsLive,
         boosts: Bonfire.UI.Me.ProfileBoostsLive,
         followers: Bonfire.UI.Social.ProfileFollowsLive,
         followed: Bonfire.UI.Social.ProfileFollowsLive,
      ],
      navigation: [
         timeline: "timeline",
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
   smart_input_components: [
      post: Bonfire.UI.Social.WritePostContentLive,
   ]
