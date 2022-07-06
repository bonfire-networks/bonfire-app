import Config

# Please note that these are defaults meant to be overriden in Settings rather than edited here
config :bonfire, :ui,
   theme: [
      instance_name: "Bonfire",
      instance_theme: "bonfire",
      instance_icon: "/images/bonfire-icon.png",
      instance_image: "/images/bonfires.png",
      instance_description: "This is a bonfire demo instance for testing purposes",
      instance_welcome: [
         title: "👋 Welcome",
         description: "
Bonfire is a federated social networking toolkit for communities and individuals to design, operate and control their digital lives, by assembling their own social networks like lego blocks in order to cultivate safe and private spaces while being interconnected with the rest of the 'fediverse' and the internet at wide on their own terms.
The bonfire ecosystem will include:
   1. Bonfire apps/flavours: Open source federated networks that are ready to be installed and used for different purposes. Made up of a set of pre-configured extensions.
   2. Bonfire extensions: Forkable/customisable modules providing different features or UX, ready to be used within bonfire apps.
   3. Bonfire device: A plug-and-play device to have anything you need in your hands (literally).
   4. Bonfire cloud services: Your public identity in the cloud can receive messages even when your device is offline. Syncs your Bonfire device with the fediverse, and deletes already-synced data from the cloud. Open source so others can host equivalent services.

More details at https://bonfirenetworks.org",
         links: [
            "About Bonfire": "https://bonfirenetworks.org/",
            "Forum": "https://socialhub.activitypub.rocks/g/bonfire/activity/posts",
            "Community Chat": "https://matrix.to/#/%23bonfire-networks:matrix.org",
            "Contribute": "https://bonfirenetworks.org/contribute/"
         ]
      ]
   ], # end theme
   # rich_text_editor_disabled: true,
   rich_text_editor: Bonfire.Editor.Quill,
   # rich_text_editor: Bonfire.Editor.Ck,
   font_family: "Inter (Latin Languages)", # default
   font_families: [
      "Inter (Latin Languages)",
      "Inter (More Languages)",
      "Noto Sans (Latin Languages)",
      "Noto Sans (More Languages)",
      "OpenDyslexic"
   ],
   theme: "bonfire",
   themes: [
     "bonfire",
     "light",
     "dark",
     "cupcake",
     "bumblebee",
     "emerald",
     "corporate",
     "synthwave",
     "retro",
     "cyberpunk",
     "valentine",
     "halloween",
     "garden",
     "forest",
     "aqua",
     "lofi",
     "pastel",
     "fantasy",
     "wireframe",
     "black",
     "luxury",
     "dracula",
     "cmyk",
     "autumn",
     "business",
     "acid",
     "lemonade",
     "night",
     "coffee",
     "winter"
   ],

   show_trending_tags: [
      disabled: false,
      for_last_x_days: 30,
      limit: 8,
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
         timeline: Bonfire.UI.Social.ProfileTimelineLive,
         # private: Bonfire.UI.Social.MessageThreadsLive,
         posts: Bonfire.UI.Social.ProfilePostsLive,
         boosts: Bonfire.UI.Social.ProfileBoostsLive,
         followers: Bonfire.UI.Social.ProfileFollowsLive,
         followed: Bonfire.UI.Social.ProfileFollowsLive,
         follow: Bonfire.UI.Me.ProfileRemoteFollowLive,
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
   ],
  invites_component: Bonfire.Invite.Links.Web.InvitesLive
