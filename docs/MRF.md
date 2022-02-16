# Message Rewrite Facility

**WARNING: Due to how this app currently handles its configuration, MRF is only usable if you're building your own docker image.**

The Message Rewrite Facility (MRF) is a subsystem that is implemented as a series of hooks that allows the administrator to rewrite or discard messages.

Possible uses include:

- marking incoming messages with media from a given account or instance as sensitive
- rejecting messages from a specific instance
- rejecting reports (flags) from a specific instance
- removing/unlisting messages from the public timelines
- removing media from messages
- sending only public messages to a specific instance

The MRF provides user-configurable policies. The default policy is `NoOpPolicy`, which disables the MRF functionality. Bonfire also includes an easy to use policy called `SimplePolicy` which maps messages matching certain pre-defined criterion to actions built into the policy module.
It is possible to use multiple, active MRF policies at the same time.

## Using `SimplePolicy`

`SimplePolicy` is capable of handling most common admin tasks.

To use `SimplePolicy`, you must enable it. Do so by adding the following to your `:instance` config object, so that it looks like this:

```
config :bonfire, :instance,
  [...]
  rewrite_policy: ActivityPub.MRF.SimplePolicy
```

Once `SimplePolicy` is enabled, you can configure various groups in the `:mrf_simple` config object. These groups are:

- `media_removal`: Servers in this group will have media stripped from incoming messages.
- `media_nsfw`: Servers in this group will have the #nsfw tag and sensitive setting injected into incoming messages which contain media.
- `reject`: Servers in this group will have their messages rejected.
- `report_removal`: Servers in this group will have their reports (flags) rejected.

Servers should be configured as lists.

### Example

This example will enable `SimplePolicy`, block media from `illegalporn.biz`, mark media as NSFW from `porn.biz` and `porn.business`, reject messages from `spam.com` and block reports (flags) from `troll.mob`:

```
config :activity_pub, :instance,
  rewrite_policy: [ActivityPub.MRF.SimplePolicy]

config :activity_pub, :mrf_simple,
  media_removal: ["illegalporn.biz"],
  media_nsfw: ["porn.biz", "porn.business"],
  reject: ["spam.com"],
  report_removal: ["troll.mob"]

```

### Use with Care

The effects of MRF policies can be very drastic. It is important to use this functionality carefully. Always try to talk to an admin before writing an MRF policy concerning their instance.

## Writing your own MRF Policy

As discussed above, the MRF system is a modular system that supports pluggable policies. This means that an admin may write a custom MRF policy in Elixir or any other language that runs on the Erlang VM, by specifying the module name in the `rewrite_policy` config setting.

For example, here is a sample policy module which rewrites all messages to "new message content":

```elixir
# This is a sample MRF policy which rewrites all Notes to have "new message
# content."
defmodule Site.RewritePolicy do
  @behavior ActivityPub.MRF

  # Catch messages which contain Note objects with actual data to filter.
  # Capture the object as `object`, the message content as `content` and the
  # entire activity itself as `activity`.
  @impl true
  def filter(%{"type" => "Create", "object" => %{"type" => "Note", "content" => content} = object} = message)
      when is_binary(content) do
    # Subject / CW is stored as summary instead of `name` like other AS2 objects
    # because of Mastodon doing it that way.
    summary = object["summary"]

    # edits go here.
    content = "new message content"

    # Assemble the mutated object.
    object =
      object
      |> Map.put("content", content)
      |> Map.put("summary", summary)

    # Assemble the mutated activity.
    {:ok, Map.put(activity, "object", object)}
  end

  # Let all other messages through without modifying them.
  @impl true
  def filter(message), do: {:ok, message}
end
```

If you save this file as `lib/site/mrf/rewrite_policy.ex`, it will be included when you next rebuild Bonfire. You can enable it in the configuration like so:

```
config :activity_pub, :instance,
  rewrite_policy: [
    ActivityPub.MRF.SimplePolicy,
    Site.RewritePolicy
  ]
```
