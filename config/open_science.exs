import Config

#### Extension-specific compile-time configuration goes here, everything else should be in `OpenScience.RuntimeConfig`

config :bonfire, :ui,
  theme: [
    instance_name: "Open Science Network",
    instance_icon: "/images/bonfire-icon.png",
    # instance_image: "https://openscience.network/assets/icon.png",
    instance_description:
      "A network of scientists, researchers and developers building the next generation of open science digital spaces."
  ]

# The dashboard's main-area widgets, in default order: ids of widgets in `Bonfire.UI.Common.Widgets.registry/0`. Instances set their own defaults and people their own choice in dashboard settings.
config :bonfire, Bonfire.Web.Views.DashboardLive,
  widgets: [
    main: [:welcome, :instance_pinned, :trending_discussions, :polls_closing_soon, :suggested_profiles]
  ]
