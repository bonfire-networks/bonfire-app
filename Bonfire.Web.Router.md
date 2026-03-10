# `Bonfire.Web.Router`
[🔗](https://github.com/bonfire-networks/bonfire-app/blob/main/lib/bonfire/web/router/routes.ex#L224)

# `absinthe_before_send`

# `account_required`

# `activity_json`

# `activity_json_or_html`

# `admin_required`

# `api_browser`

Used to serve the GraphiQL API browser

# `authorize`

# `basic`

# `basic_html`

# `basic_json`

# `browser`

# `browser_accepts`

# `browser_or_cacheable`

# `browser_render`

# `browser_security`

# `browser_ui`

# `browser_unsafe`

# `cacheable`

# `cacheable_page`

# `cacheable_post_public`

# `call`

Callback invoked by Plug on every request.

# `check_provider_enabled`

# `early_hints_authed`

# `formatted_routes`

# `generate_reverse_router!`

(re)generates the reverse router (useful so it can be re-generated when extensions are enabled/disabled)

# `graphql`

Used to serve GraphQL API queries

# `guest_only`

# `host_meta`

# `html_only`

# `init`

Callback required by Plug that initializes the router
for serving web requests.

# `load_authorization`

# `load_current_auth`

# `masto_api`

# `rate_limit`

Rate limit plug for controllers.

Reads configuration from `Application.get_env(:bonfire, :rate_limit)[key_prefix]` 
with fallback to default options provided in the plug call.

## Options

  * `:key_prefix` - Atom prefix for the rate limit bucket key (required)
  * `:scale_ms` - Default time window in milliseconds (can be overridden by config)
  * `:limit` - Default number of requests (can be overridden by config)
  * `:method` - Optional HTTP method to rate limit (e.g., "POST"). If provided, only requests
                with this method will be rate limited. All other methods pass through.

## Examples

    # Rate limit all requests
    plug :rate_limit, 
      key_prefix: :api,
      scale_ms: 60_000,
      limit: 100
    
    # Rate limit only POST requests (form submissions)
    plug :rate_limit, 
      key_prefix: :forms,
      scale_ms: 60_000,
      limit: 5,
      method: "POST"

# `require_authenticated_user`

# `require_confirmed`

# `safe_protect_from_forgery`

Wraps `protect_from_forgery` to gracefully handle stale CSRF tokens by renewing the session and redirecting back.

# `set_locale`

# `signed_activity_pub_fetch`

# `signed_activity_pub_incoming`

# `static_generator`

# `throttle_forms`

# `user_required`

# `verified_route?`

# `webfinger`

# `well_known_nodeinfo`

---

*Consult [api-reference.md](api-reference.md) for complete listing*
