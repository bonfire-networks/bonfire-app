# Bonfire v1.0.2-social-rc.9 - API Reference

## Modules

- Bonfire utilities
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
  - [Bonfire.Localise](Bonfire.Localise.md): Runs at compile-time to include dynamic strings (like verb names and object types) in localisation string extraction.

  - [Bonfire.RuntimeConfig](Bonfire.RuntimeConfig.md)
  - [Bonfire.Seeder](Bonfire.Seeder.md): A way to have data seeds that work similarly to migrations.

## Mix Tasks

- Utilities
  - [mix bonfire.load_testing](Mix.Tasks.Bonfire.LoadTesting.md)

