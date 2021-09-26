import Config

schema = Bonfire.GraphQL.Schema

config :bonfire_api_graphql,
  graphql_schema_module: schema

config :absinthe,
  schema: schema
