import Config

config :bonfire_quantify,
  templates_path: "lib"

config :bonfire_quantify, Bonfire.Quantify.Units, valid_contexts: [Bonfire.Quantify.Units, Bonfire.Data.Identity.User]
