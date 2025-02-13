import Config

schema = Bonfire.API.GraphQL.Schema

config :bonfire_api_graphql,
  graphql_schema_module: schema

config :absinthe,
  schema: schema
