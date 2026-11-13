# ActivityPub for Elixir

An Elixir library that enables a Phoenix app to federate with the fediverse over [ActivityPub](https://www.w3.org/TR/activitypub/). It is the federation layer used by [Bonfire](https://bonfirenetworks.org) and [kazarma](https://kazar.ma/), and it is built to be used by other apps too.

Getting federation right means implementing ActivityPub, ActivityStreams, and many more specs, including signatures, discovery, fetching, delivery and retries. This library does that work, so your app's users can follow and be followed, post, reply, boost and react across servers. It doesn't dictate your app's data model. Incoming activities are normalised and temporarily stored as ActivityStreams JSON objects, and handed to your app through an adapter module. Outgoing ones are queued and delivered to each recipient's inbox. Your app decides what an activity means for its own users, posts and follows.

## Status

It runs in production on every Bonfire instance. The API is still evolving but in a backwards-compatible way.

## What it does

- Serves actors, objects and collections as ActivityStreams JSON, with the ActivityPub server-to-server inbox and outbox. 
- The client-to-server (C2S) API is available too.
- Finds and is found through WebFinger, so `@user@your.host` works from other servers.
- Signs what it sends with HTTP signatures (RFC 9421 or draft-cavage, whichever the receiving server uses) and Data Integrity proofs (FEP-8b32, `eddsa-jcs-2022`).
- Checks what it receives, with HTTP signatures (RFC 9421 or draft-cavage), Linked Data signatures (`RsaSignature2017`, the ones Mastodon emits) and Data Integrity proofs (FEP-8b32, `eddsa-jcs-2022` and `mldsa44-jcs-2024`, with keys from the actor's `assertionMethod`, FEP-521a).
- Fetches remote actors and objects, including the objects nested in an activity, and caches them.
- Delivers and receives through [Oban](https://hexdocs.pm/oban) queues, retries failed deliveries, and tracks which instances are unreachable.
- Enforces moderation at the instance level with MRF policies: rejecting or limiting instances, removing media, and filtering keywords.

It needs Elixir 1.20.2 or later, an Ecto repo and Oban.

## Related libraries

- [nodeinfo](https://github.com/bonfire-networks/nodeinfo): serves instance information with the [NodeInfo](https://nodeinfo.diaspora.software) standard, which other servers read to learn what software an instance runs (not a dependency: add it alongside)
- [http_signatures](https://github.com/bonfire-networks/http_signatures): signs and checks HTTP signatures, used by this library (a fork of Akkoma's)

And for an example of how to integrate this library's adapter into an app, you can look at [Bonfire's adapter](https://github.com/bonfire-networks/bonfire_federate_activitypub).

## Credits and licence

Parts of the code come from [Akkoma](https://akkoma.social). Licensed under the GNU AGPLv3 (see `LICENCE`).

## Installation

1. Add this library to your dependencies in `mix.exs`

```
defp deps do
  [...]
  {:activity_pub, git: "https://github.com/bonfire-networks/activity_pub.git", branch: "stable"} # branch can be "stable", or "develop" for the bleeding edge
end
```

2. Create an adapter module. To start, one created at `lib/my_app/adapter.ex` might look like this:

```elixir
defmodule MyApp.Adapter do
  @moduledoc """
  Adapter functions delegated from the `ActivityPub` Library
  """

  @behaviour ActivityPub.Federator.Adapter
end
```

Thanks to the `@behaviour`, Elixir warns you about each callback of `ActivityPub.Federator.Adapter` you have not implemented yet, such as `base_url/0`, `get_actor_by_id/1`, `get_actor_by_username/1` and `handle_activity/1`. Your app still starts. 

The behaviour module documents every callback, and which ones are optional. These callbacks are how the library reads your actors and objects, and how it hands incoming activities to your app. 

Then set it in config:

```
config :activity_pub, :adapter, MyApp.Adapter
```

3. Set your application repo in config

```
config :activity_pub, :repo, MyApp.Repo
```

4. Create a new ecto migration and call `ActivityPub.Migration.up/0` from it

5. Inject AP routes to your router by adding `use ActivityPub.Web.Router` to your app's router module

6. Copy the default AP config to your app's `config.exs`

```
config :activity_pub, :mrf_simple,
  media_removal: [],
  media_nsfw: [],
  report_removal: [],
  accept: [],
  avatar_removal: [],
  banner_removal: []

config :activity_pub, :instance,
  hostname: "example.com",
  federation_publisher_modules: [ActivityPub.Federator.APPublisher],
  federation_reachability_timeout_days: 7,
  federating: true,
  rewrite_policy: []

config :activity_pub, :http,
  proxy_url: nil,
  user_agent: "Your app name",
  send_user_agent: true,
  adapter: [
    ssl_options: [
      # Workaround for remote server certificate chain issues
      partial_chain: &:hackney_connect.partial_chain/1,
      # We don't support TLS v1.3 yet
      versions: [:tlsv1, :"tlsv1.1", :"tlsv1.2"]
    ]
  ]
  ```

7. Change the hostname value in the instance config block to your instance's hostname 

8. If you don't already have Oban set up, follow the [Oban installation instructions](https://hexdocs.pm/oban/installation.html#content) and add the AP queues:

```
config :my_app, Oban, queues: [federator_incoming: 50, federator_outgoing: 50, remote_fetcher: 20]
```

Now you should be able to compile and run your app and move over to integration.
