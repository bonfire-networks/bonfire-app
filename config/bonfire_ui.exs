import Config

config :bonfire, :ui,
   sidebar_components: [
      Bonfire.UI.Social.SidebarNavigationLive,
      Bonfire.UI.Reflow.SidebarNavigationLive
    ]
