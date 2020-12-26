use Mix.Config

config :bonfire_valueflows,
  web_module: Bonfire.Web,
  repo_module: Bonfire.Repo,
  endpoint_module: Bonfire.Web.Endpoint,
  graphql_schema_module: Bonfire.GraphQL.Schema,
  user_schema: Bonfire.Data.Identity.User,
  org_schema: Bonfire.Data.Identity.User,
  valid_agent_schemas: [Bonfire.Data.Identity.User],
  all_types: []
