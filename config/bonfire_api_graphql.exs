import Config

config :bonfire_api_graphql,
  env: Mix.env(),
  repo_module: Bonfire.Repo,
  graphql_schema_module: Bonfire.GraphQL.Schema
