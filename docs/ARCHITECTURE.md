# Bonfire Architecture

## Hacking

This is an unusual piece of software, developed in an unusual
way. It started with requests by Moodle users to be able to share and
collaborate on educational resources with their peers.

Hacking on it is actually pretty fun. The codebase has a unique
feeling to work with and we've relentlessly refactored to manage the
ever-growing complexity that a distributed social network
implies. This said, it is not easy to understand without context,
which is what this section is here to provide.

## Design Decisions

Feature goals:

- Flexibility for developers and deployments.
- Integrated federation with the existing fediverse.

Operational goals:

- Easy to set up and run.
- Light on resources for small deployments.
- Scalable for large deployments.

Operationally, there's a tension between wanting to be able to scale
instances and not wanting to burden small instances with
high resource requirements or difficult setup.

There are no easy answers to this. Our current solution is heavily
reliant on postgresql. We will monitor perforamnce and scaling and
continually evolve our strategy.

## Stack

Our implementation language is [Elixir](https://www.elixir-lang.org/),
a language designed for building reliable systems. We use the
[Phoenix](https://www.phoenixframework.org/) web framework.

Some extensions use LiveView and Surface for UI components and views.

Some extensions use the [Absinthe](https://absinthe-graphql.org/) GraphQL library to deliver a GraphQL API.

We like our stack and we have no interest in rewriting in PHP, thanks
for not asking.

## Code Structure

The server code is broadly composed of these parts.

- `Bonfire.*` - Core application logic (very little code).
- `Bonfire.*.*` - Bonfire extensions (eg `Bonfire.Social.Posts`)
- `Bonfire.Data.*` - Schemas etc.
- `Bonfire.Web.*` - Phoenix webapp
- `Bonfire.GraphQL.*` - Optional GraphQL API.
- `ActivityPub` - ActivityPub S2S models, logic and various helper modules (adapted Pleroma code)
- `ActivityPubWeb` - ActivityPub S2S REST endpoints, activity ingestion and push federation facilities (adapted Pleroma code)
- `ValueFlows.*` - economic extensions

### `Bonfire`

This namespace contains the core business logic. Every `Bonfire` object type has at least context module (e. g. `Bonfire.Communities`), a model/schema module (`Bonfire.Communities.Community`) and a queries module (`Bonfire.Communities.Queries`).

All `Bonfire` objects use an ULID as their primary key. We use the pointers library (`Bonfire.Common.Pointers`) to reference any object by its primary key without knowing what type it is beforehand. This is very useful as we allow for example following or liking many different types of objects and this approach allows us to store the context of the like/follow by only storing its primary key (see `Bonfire.Follows.Follow`) for an example.

All context modules have a `one/1` and `many/1` function for fetching objects. These take a keyword list as filters as arguments allowing objects to be fetched by arbitrary criteria defined in the queries modules.

Examples:

```
Communities.one(username: "bob") # Fetching by username
Collections.many(community: "01E9TQP93S8XFSV2ZATX1FQ528") # Fetching collections by its parent community
Resources.many(deleted: nil) # Fetching all undeleted communities
```

Context modules also have functions for creating, updating and deleting objects. These actions are passed to the AP layer via the `Bonfire.Workers.APPublishWorker` module.

#### Contexts

The `Bonfire` namespace is occupied mostly by contexts. These are
top level modules which comprise a grouping of:

- A top level library module
- Additional library modules
- OTP services
- Ecto schemas

Here are some of the current extensions, or modules therin:

- `Bonfire.Boundaries` (for managing and querying email whitelists)
- `Bonfire.Social.FeedActivities` and `Bonfire.Social.Activities` and`Bonfire.Social.Activities` (for managing and querying activities, the unit of a feed)
- `Bonfire.Social.Feeds` (for managing and querying feeds)
- `Bonfire.Social.Flags` (for managing and querying flags)
- `Bonfire.Social.Follows` (for managing and querying follows)
- `Bonfire.Instance` (for managing the local instance)
- `Bonfire.Me.Mails` (for rendering and sending emails)
- `Bonfire.Social.Threads` (for managing and querying threads and comments)
- `Bonfire.Me.Users` (for managing and querying both local and remote users)
- `Bonfire.Files` (for managing uploaded content)
- `Bonfire.Me.Characters` (a shared abstraction over users, communities, collections, and other objects that need to have feeds and act as an actor in ActivityPub land)
- `Bonfire.Search` (local search indexing and search API, powered by Meili)

#### Additional extensions and modules

- `Bonfire.Application` (OTP application)
- `Bonfire.Federate.ActivityPub` (ActivityPub integration)
- `Bonfire.Common` (stuff that gets used everywhere)
- `Bonfire.GraphQL` (GraphQL abstractions)
- `Bonfire.Queries` (Helpers for making queries)
- `Bonfire.Repo` (Ecto repository)

### `Bonfire.Web`

Structure:

- Endpoint
- Router
- Controllers
- Views
- Plugs
- GraphQL
  - Schemas
  - Resolvers
  - Middleware
  - Pipeline
  - Flows

See the [GraphQL API documentation](./GRAPHQL.md)

### `ActivityPub`

This namespace handles the ActivityPub logic and stores AP activitities. It is largely adapted Pleroma code with some modifications, for example merging of the activity and object tables and new actor object abstraction.

It also contains some functionality that isn't part of the AP spec but is required for federation:

- `ActivityPub.Keys` - Generating and handling RSA keys for messagage signing
- `ActivityPub.Signature` - Adapter for the HTTPSignature library
- `ActivityPub.WebFinger` - Implementation of the WebFinger protocol
- `ActivityPub.HTTP` - Module for making HTTP requests (wrapper around tesla)
- `ActivityPub.Instances` - Module for storing reachability information about remote instances

`ActivityPub` contains the main API and is documented there. `ActivityPub.Adapter` defines callback functions for the AP library.

### `ActivityPubWeb`

This namespace contains the AP S2S REST API, the activity ingestion pipeline (`ActivityPubWeb.Transmogrifier`) and the push federation facilities (`ActivityPubWeb.Federator`, `ActivityPubWeb.Publisher` and others). The outgoing federation module is designed in a modular way allowing federating through different protocols in the future.

### `ActivityPub` interaction in our application logic

The callback functions defined in `ActivityPub.Adapter` are implemented in `Bonfire.ActivityPub.Adapter`. Facilities for calling the ActivityPub API are implemented in `Bonfire.ActivityPub.Publisher`. When implementing federation for a new object type it needs to be implemented both ways: both for outgoing federation in `Bonfire.ActivityPub.Publisher` and for incoming federation in `Bonfire.ActivityPub.Adapter`.

## Naming

It is said that naming is one of the four hard problems of computer
science (along with cache management and off-by-one errors). We don't
claim our scheme is the best, but we do strive for consistency.

Naming rules:

- Context names all begin `Bonfire.` and are named in plural where possible.
- Everything within a context begins with the context name and a `.`
- Ecto schemas should be named in the singular
- Database tables should be named in the singular
- Acronyms in module names should be all uppercase
- OTP services should have the `Service` suffix (without a preceding `.`)
