import Config

config :bonfire_valueflows,
  valid_agent_schemas: [Bonfire.Data.Identity.User],
  preset_boundary: "local"
