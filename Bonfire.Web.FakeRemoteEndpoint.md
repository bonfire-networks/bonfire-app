# `Bonfire.Web.FakeRemoteEndpoint`
[🔗](https://github.com/bonfire-networks/bonfire-app/blob/main/lib/bonfire/web/fake_remote_endpoint.ex#L1)

# `broadcast`

# `broadcast!`

# `broadcast_from`

# `broadcast_from!`

# `call`

# `child_spec`

Returns the child specification to start the endpoint
under a supervision tree.

# `config`

Returns the endpoint configuration for `key`

Returns `default` if the key does not exist.

# `config_change`

Reloads the configuration given the application environment changes.

# `host`

Returns the host for the given endpoint.

# `include_assets`

# `include_assets`

# `init`

# `local_broadcast`

# `local_broadcast_from`

# `log_ip`

# `node_name`

# `path`

Generates the path information when routing to this endpoint.

# `plug_timing_checkpoint`

# `publish_mutation`

# `publish_subscription`

# `reload!`

# `save_accept_header`

# `save_url_in_process`

# `script_name`

Generates the script name.

# `server_info`

Returns the address and port that the server is running on

# `start_link`

Starts the endpoint supervision tree.

All other options are merged into the endpoint configuration.

# `static_integrity`

Generates a base64-encoded cryptographic hash (sha512) to a static file
in `priv/static`. Meant to be used for Subresource Integrity with CDNs.

# `static_lookup`

Returns a two item tuple with the first item being the `static_path`
and the second item being the `static_integrity`.

# `static_path`

Generates a route to a static file in `priv/static`.

# `static_url`

Generates the static URL without any path information.

It uses the configuration under `:static_url` to generate
such. It falls back to `:url` if `:static_url` is not set.

# `struct_url`

Generates the endpoint base URL but as a `URI` struct.

It uses the configuration under `:url` to generate such.
Useful for manipulating the URL data and passing it to
URL helpers.

# `subscribe`

# `unsubscribe`

# `url`

Generates the endpoint base URL without any path information.

It uses the configuration under `:url` to generate such.

---

*Consult [api-reference.md](api-reference.md) for complete listing*
