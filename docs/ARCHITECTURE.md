# Bonfire Architecture

## Hacking

Bonfire is an unusual piece of software, developed in an unusual way. 
It originally started with requests by Moodle users to be able to share and collaborate on educational resources with their peers and has been forked and evolved a lot since then.

Hacking on it is actually pretty fun. The codebase has a unique feeling to work with and we've relentlessly refactored to manage the ever-growing complexity that a distributed social networking toolkit implies. 
That said, it is not easy to understand without context, which is what this document is here to provide.


## Design Decisions

Feature goals:

- Flexibility for developers and users.
- Extreme configurability and extensibility.
- Integrated federation with the existing fediverse.

Operational goals:

- Easy to set up and run.
- Light on resources for small deployments.
- Scalable for large deployments.


## Stack

Our main implementation language is [Elixir](https://www.elixir-lang.org/), which is designed for building reliable systems. 

We use the [Phoenix](https://www.phoenixframework.org/) web framework with [LiveView](https://hexdocs.pm/phoenix_live_view/) and [Surface](https://surface-ui.org/documentation) for UI components and views.

Some extensions use the [Absinthe](https://absinthe-graphql.org/) GraphQL library to expose an API.


## Code Structure

The code is broadly composed of these namespaces:

- `Bonfire.*` - Core application logic (very little code).
- `Bonfire.*.*` - Bonfire extensions (eg `Bonfire.Social.Posts`) containing mostly context modules, APIs, and routes
- `Bonfire.Data.*` - Extensions containing database schemas and migrations 
- `Bonfire.UI.*` - UI component extensions
- `Bonfire.*.*.LiveHandler` - Backend logic to handle events in the frontend
- `Bonfire.Editor.*` (pluggable text editors, eg. CKEditor for WYSIWYG markdown input)
- `Bonfire.GraphQL.*` - Optional GraphQL API
- `Bonfire.Federate.*` - Optional Federation hooks
- `ActivityPub` - ActivityPub S2S models, logic and various helper modules 
- `ActivityPubWeb` - ActivityPub S2S REST endpoints, activity ingestion and push federation facilities 
- `ValueFlows.*` - economic extensions implementing the [ValueFlows vocabulary](https://www.valueflo.ws)


Contexts are were we put any core logic. A context often is circumscribed to providing logic for a particular object type (e. g. `Bonfire.Social.Posts` implements `Bonfire.Data.Social.Post`). 

All Bonfire objects use an ULID as their primary key. We use the `Pointers` library (with extra logic in `Bonfire.Common.Pointers`) to reference any object by its primary key without knowing what type it is beforehand. This is very useful as it allows for example following or liking many different types of objects (as opposed to say only a user or a post) and this approach allows us to store the context of the like/follow by only storing its primary key (see `Bonfire.Data.Social.Follow`) for an example.

Context modules usually have `one/2`, `many/2`, and `many_paginated/1` functions for fetching objects, which in turn call a `query/2` function. These take a keyword list as filters (and an optional `opts` argument) allowing objects to be fetched by arbitrary criteria.

Examples:

```
Users.one(username: "bob") # Fetching by username
Posts.many_paginated(by: "01E9TQP93S8XFSV2ZATX1FQ528") # List a page of posts by its author
EconomicResources.many(deleted: true) # List any deleted resources
```

Context modules also have functions for creating, updating and deleting objects, as well as hooks for federating or indexing in the search engine.


Here is an incomplete sample of some of current extensions and modules:

- `Bonfire.Me.Accounts` (for managing and querying local user accounts)
- `Bonfire.Me.Users` (for managing and querying both local and remote user identities and profiles)
- `Bonfire.Boundaries` (for managing and querying circles, ACLs, permissions...)
- `Bonfire.Social.FeedActivities`, `Bonfire.Social.Feeds` and `Bonfire.Social.Activities` (for managing and querying activities and feeds)
- `Bonfire.Social.Posts` and `Bonfire.Social.PostContents` (for managing and querying posts)
- `Bonfire.Social.Threads` (for managing and querying threads and comments)
- `Bonfire.Social.Flags` (for managing and querying flags)
- `Bonfire.Social.Follows` (for managing and querying follows)
- `Bonfire.Classify` (for managing and querying categories, topics, and the like)
- `Bonfire.Tag` (for managing and querying tags and mentions)
- `Bonfire.Geolocate` (for managing and querying locations and geographical coordinates)
- `Bonfire.Quantify` (for managing and querying units and measures)

#### Additional extensions, libraries, and modules

- `Bonfire.Common` and `Bonfire.Common.Utils` (stuff that gets used everywhere)
- `Bonfire.Application` (OTP application)
- `Bonfire.MixProject` (Mix application configuration and helpers)
- `Bonfire.Me.Characters` (a shared abstraction over users, organisations, categories, and other objects that need to have feeds and behave as an actor in ActivityPub land)
- `Bonfire.Federate.ActivityPub` and `ActivityPub` (ActivityPub integration)
- `Bonfire.Search` (local search indexing and search API, powered by Meili)
- `Bonfire.Mailer`, `Bonfire.Me.Mails`, and `Bamboo` (for rendering and sending emails)
- `Bonfire.Files`, `Waffle`, `TreeMagic` and `TwinkleStar` (for managing uploaded content)
- `Bonfire.GraphQL` (GraphQL API abstractions)
- `Queery` and `Bonfire.Repo.Query` (Helpers for making queries on the database)
- `Bonfire.Repo` (Ecto repository)
- `Flexto` (to extend DB schemas in config, especially useful for adding associations)
- `AbsintheClient` (for querying the API from within the server)


### General structure

- Bonfire app
  - A [flavour](../README.md#flavours) running `Bonfire.Application` as supervisor
    - Configs assembled from extensions at `flavour/$FLAVOUR/config`
    - Phoenix at `Bonfire.Web.Endpoint`
      - Routes assembled from extensions at `Bonfire.Web.Router` 
    - GraphQL schema assembled from extensions at `Bonfire.GraphQL.Schema`
    - Database migrations assembled from extensions at `flavour/$FLAVOUR/repo/migrations`
    - Data seeds assembled from extensions at `flavour/$FLAVOUR/repo/seeds`
    - Extensions and libraries as listed in `flavour/$FLAVOUR/config/deps.*`
      - Extensions defining schemas and migrations (usually `Bonfire.Data.*`)
        - Schemas
        - Migrations defined as functions in the schema modules in `lib/`
        - Migration templates calling those functions in `priv/repo/migrations` which are then copied into an app flavour's migrations
      - Extensions implementing features or groups of features (eg. `Bonfire.Me`)
        - Config template which is then copied into an app flavour's config (eg `config/bonfire_me.exs`)
        - Contexts (eg `Bonfire.Me.Users`)
          - Sometimes LiveHandlers for handling frontend events in the backend (eg `Bonfire.Me.Users.LiveHandler`)
        - Routes (eg `Bonfire.Me.Web.Routes`)
          - Controllers and/or Views (eg `Bonfire.Me.Web.CreateUserController` and `Bonfire.Me.Web.CreateUserLive`)
        - API (eg `Bonfire.Me.API.GraphQL`), refer to [GraphQL API documentation](./GRAPHQL.md)
          - Schemas
          - Resolvers
        - Sometimes Plugs (eg `Bonfire.Web.Plugs.UserRequired` and `Bonfire.Web.LivePlugs.UserRequired`)
      - Other extensions or libraries (eg `Pointers` or `Bonfire.Common` which are used by most other extensions)
          

## Naming

It is said that naming is one of the four hard problems of computer science (along with cache management and off-by-one errors). We don't claim our scheme is the best, but we do strive for consistency.

### Naming guidelines

- Module names mostly begin with `Bonfire.` unless they belong to a more generic library (eg `Pointers` or `ValueFlows`)
- Everything within an extension begins with the context name and a `.` (eg `Bonfire.Social.Migrations`)
- Database schemas should be named in the singular (eg `Bonfire.Data.Social.Post`)
- Context modules are named in plural where possible (eg `Bonfire.Social.Posts`)
- Other modules within a context begins with the context name and a `.` (eg `Bonfire.Social.Posts.LiveHandler`)
- Modules use UpperCamelCase while functions use snake_case
- Acronyms in module names should be all uppercase (eg `Bonfire.Social.APActivities`)


## Federation libraries

### `ActivityPub`

This namespace handles the ActivityPub logic and stores AP activities. It is largely adapted Pleroma code with some modifications, for example merging of the activity and object tables and new actor object abstraction.

Also refer to [MRF documentation](./MRF.md) to learn how to rewrite or discard messages.

`ActivityPub` contains the main API and is documented there. 

`ActivityPub.Adapter` defines callback functions for the AP library.

`ActivityPub` also contains some functionality that isn't part of the AP spec but is required for federation:

- `ActivityPub.Keys` - Generating and handling RSA keys for messagage signing
- `ActivityPub.Signature` - Adapter for the HTTPSignature library
- `ActivityPub.WebFinger` - Implementation of the WebFinger protocol
- `ActivityPub.HTTP` - Module for making HTTP requests (wrapper around tesla)
- `ActivityPub.Instances` - Module for storing reachability information about remote instances


### `ActivityPubWeb`

This namespace contains the AP S2S REST API, the activity ingestion pipeline (`ActivityPubWeb.Transmogrifier`) and the push federation facilities (`ActivityPubWeb.Federator`, `ActivityPubWeb.Publisher` and others). The outgoing federation module is designed in a modular way allowing federating through different protocols in the future.

### `ActivityPub` interaction in our application logic

The callback functions defined in `ActivityPub.Adapter` are implemented in `Bonfire.ActivityPub.Adapter`. Facilities for calling the ActivityPub API are implemented in `Bonfire.ActivityPub.Publisher`. When implementing federation for a new object type it needs to be implemented both ways: both for outgoing federation in `Bonfire.ActivityPub.Publisher` and for incoming federation in `Bonfire.ActivityPub.Adapter`.

