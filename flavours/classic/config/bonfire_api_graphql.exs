# SPDX-FileCopyrightText: 2023 Bonfire contributors <https://github.com/bonfire-networks/bonfire-app/graphs/contributors>
#
# SPDX-License-Identifier: AGPL-3.0-only

import Config

schema = Bonfire.API.GraphQL.Schema

config :bonfire_api_graphql,
  graphql_schema_module: schema

config :absinthe,
  schema: schema
