# ActivityPub

ActivityPub Library for elixir.

**WORK IN PROGRESS, TESTING FEDERATION WITH DIFFERENT IMPLEMENTATIONS IS UNDERWAY**

## Installation

1. Add this library to your dependencies in `mix.exs`

```
defp deps do
  [...]
  {:activity_pub, git: "https://github.com/bonfire-networks/activity_pub.git", branch: "stable"} # branch can "stable", or "develop" for the bleeding edge
end
```

2. Create an adapter module. To start, one created at
   `lib/my_app/adapter.ex` might look like

```elixir
defmodule MyApp.Adapter do
  @moduledoc """
  Adapter functions delegated from the `ActivityPub` Library
  """

  @behaviour ActivityPub.Federator.Adapter
end
```

Note that, due to the defined `@behavior`, Elixir will warn you that
the required functions

  * `base_url/0`
  * `get_actor_by_id/1`
  * `get_actor_by_username/1`
  * `get_follower_local_ids/1`
  * `get_following_local_ids/1`
  * `get_redirect_url/1`
  * `handle_activity/1`
  * `maybe_create_remote_actor/1`
  * `maybe_publish_object/2`
  * `update_local_actor/2`
  * `update_remote_actor/1`

have not yet been implemented though you will be able to start your
app. Defining these allows `ActivityPub` to handle ActivityPub HTTP
and database calls and operations. An example of an implemented
adaptor can be found
[here](https://github.com/bonfire-networks/bonfire_federate_activitypub/tree/main/lib/adapter
"Link to file hosted on GitHub").

Then set it in config

```
config :activity_pub, :adapter, MyApp.Adapter
```

3. Set your application repo in config

```
config :activity_pub, :repo, MyApp.Repo
```

4. Create a new ecto migration and call `ActivityPub.Migration.up/0` from it

5. Inject AP routes to your router by adding `use ActivityPub.Web.Router` to your app's router module

6. Copy the default AP config to your app's confix.exs

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

8. If you don't already have Oban set up, follow the [Oban installation intructions](https://hexdocs.pm/oban/installation.html#content) and add the AP queues:

```
config :my_app, Oban, queues: [federator_incoming: 50, federator_outgoing: 50, remote_fetcher: 20]
```

Now you should be able to compile and run your app and move over to integration.
