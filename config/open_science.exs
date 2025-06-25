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
