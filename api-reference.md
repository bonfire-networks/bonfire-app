# Bonfire v1.0.7-social-alpha.19 - API Reference

## Modules

- Bonfire utilities
  - [Bonfire.API.GraphQL.GraphqlWSSocket](Bonfire.API.GraphQL.GraphqlWSSocket.md): `graphql-transport-ws` websocket transport for GraphQL subscriptions
(the protocol Ferry / graphql-ws clients speak), separate from the
Phoenix-channels `Absinthe.Phoenix.Socket` at `/api/socket`.
  - [Bonfire.API.GraphQL.Schema](Bonfire.API.GraphQL.Schema.md): Root GraphQL Schema.
Only active if the `Bonfire.API.GraphQL` extension is present.

  - [Bonfire.Web.Endpoint](Bonfire.Web.Endpoint.md)
  - [Bonfire.Web.FakeRemoteEndpoint](Bonfire.Web.FakeRemoteEndpoint.md)
  - [Bonfire.Web.LoadTestDashboard](Bonfire.Web.LoadTestDashboard.md): LiveDashboard page for monitoring system metrics during load testing.
  - [Bonfire.Web.Router](Bonfire.Web.Router.md)
  - [Bonfire.Web.Router.Reverse](Bonfire.Web.Router.Reverse.md)
  - [Bonfire.Web.Router.Routes](Bonfire.Web.Router.Routes.md)

- Feature extensions
  - [Bonfire.Federate.ActivityPub.LoadTesting](Bonfire.Federate.ActivityPub.LoadTesting.md)
  - [Bonfire.RuntimeConfig](Bonfire.RuntimeConfig.md)
  - [Bonfire.Seeder](Bonfire.Seeder.md): A way to have data seeds that work similarly to migrations.

## Mix Tasks

- Utilities
  - [mix bonfire.load_testing](Mix.Tasks.Bonfire.LoadTesting.md)

