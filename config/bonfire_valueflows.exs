import Config

config :bonfire_valueflows,
  valid_agent_schemas: [Bonfire.Data.Identity.User]

# the Media columns this extension's schemas point at, which `Bonfire.Files.Media.referenced_elsewhere?/2` checks before a Media row is deleted
config :bonfire_files, Bonfire.Files.Media,
  referenced_by: [
    {ValueFlows.Planning.Intent, [:image_id]},
    {ValueFlows.EconomicResource, [:image_id]},
    {ValueFlows.Knowledge.ResourceSpecification, [:image_id]}
  ]
