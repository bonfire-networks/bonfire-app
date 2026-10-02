# Bonfire.OpenID: Single Sign-On (SSO) Client & Provider

Bonfire.OpenID enables your Bonfire instance to act as both:
- **An SSO Client**: Let users log in to Bonfire using external identity providers (using OpenID Connect or OAuth2).
- **An SSO Provider**: Allow other apps to authenticate users using your Bonfire instance as provider (using OpenID Connect or OAuth2).


## Features

- **Standards**: Implements OpenID Connect 1.0 and OAuth 2.0 flows.
- **Configurable**: Add multiple providers via environment variables.
- **Secure**: Uses community libraries and best practices for authentication.


---


## SSO Client Setup (to sign in to Bonfire with external SSO providers)

### 1. Register your Bonfire instance with the external provider

- Go to the provider’s developer portal (e.g., GitHub, ORCID, your institution).
- Register a new OpenID or OAuth client.
- Set the callback/redirect URI to:
    - For orcid.org: `https://your-bonfire-instance.tld/openid/client/orcid`
    - For github.com: `https://your-bonfire-instance.tld/oauth/client/github`
    - For another OpenID provider: `https://your-bonfire-instance.tld/openid/client/openid_1`
    - For another OAuth provider: `https://your-bonfire-instance.tld/openid/client/oauth_1`
- Copy the client ID and client secret provided.

### 2. Configure Bonfire via environment variables

Set these in your `.env` or deployment environment:

#### For orcid.org:
```
ORCID_CLIENT_ID=
ORCID_CLIENT_SECRET=
```

#### For github.com:
```
GITHUB_APP_CLIENT_ID=
GITHUB_CLIENT_SECRET=
```

#### For OpenID Connect providers:
```
OPENID_1_ISSUER=https://yourprovider.example
OPENID_1_CLIENT_ID=your-client-id
OPENID_1_CLIENT_SECRET=your-client-secret
OPENID_1_DISPLAY_NAME=Your Provider Name
OPENID_1_SCOPE=openid email profile
OPENID_1_RESPONSE_TYPE=code
OPENID_1_ENABLE_SIGNUP=false
```

`OPENID_1_ISSUER` is the provider's issuer URL, with no path. OpenID Connect Discovery defines the document as the issuer plus `/.well-known/openid-configuration`, so that is all you need. If a provider serves its document somewhere non-standard, set the full URL in `OPENID_1_DISCOVERY` instead. When both are set, `OPENID_1_DISCOVERY` wins.

`OPENID_1_RESPONSE_TYPE` defaults to `code` and you will rarely want anything else. Note that `code` is a *response* type: `authorization_code` is a *grant* type, belongs in a different field, and will be rejected here.

#### For OAuth2 providers:
```
OAUTH_1_AUTHORIZE_URI=https://yourprovider.example/authorize_example_path
OAUTH_1_ACCESS_TOKEN_URI=https://yourprovider.example/token_example_path
OAUTH_1_USERINFO_URI=https://yourprovider.example/api_example_path/userinfo_example_path
OAUTH_1_CLIENT_ID=your-client-id
OAUTH_1_CLIENT_SECRET=your-client-secret
OAUTH_1_DISPLAY_NAME=Your Provider Name
OAUTH_1_ENABLE_SIGNUP=false
```

> **Note:**  
> If you set `OAUTH_1_ENABLE_SIGNUP=true` or `OPENID_1_ENABLE_SIGNUP=true`, users will be offered to sign up for Bonfire using this SSO provider, even if they do not already have a Bonfire account.  
> 
> However, some SSO providers do not provide an email address for the user. In this case, SSO-based signup will currently fail.
> 
> To avoid this, either:
> - Ensure your SSO provider supplies an email address, **or**
> - Set `OAUTH_1_ENABLE_SIGNUP=false` / `OPENID_1_ENABLE_SIGNUP=false` to require users to first create a Bonfire account and link it afterwards.


### 3. User Experience

- Users will see a "Sign in with..." button for each configured provider.
- After authenticating with the provider, users are redirected back to Bonfire and logged in (or signed up, if enabled).

- **To disable a client SSO provider**, simply comment out or remove the relevant environment variables.


### Client endpoints

| Path                                 | Purpose                        |
|--------------------------------------|--------------------------------|
| `/openid/client/:provider`           | OpenID client login/callback   |
| `/oauth/client/:provider`            | OAuth client login/callback    |

---


## SSO Provider Setup (to sign in to other apps using Bonfire as their SSO)

### 1. Enable provider mode

Bonfire’s SSO provider endpoints are currently disabled by default.  
To enable Bonfire as an SSO provider, set the following environment variable:

```
ENABLE_SSO_PROVIDER=true
```

This will activate all provider endpoints (OAuth2/OpenID Connect).  

### 2. Register client apps

Until a UI is added for this, you can register a new OAuth/OpenID client using a `curl` command, making sure that `redirect_uris` matches what your client app will use:

```
curl -X POST https://your-bonfire-instance.tld/api/v1/apps \
  -F 'client_name=Your Application Name' \
  -F 'redirect_uris=https://your-client-app.example/callback' \
  -F 'scopes=openid email profile' \
  -F 'website=https://your-client-app.example'
```

Or using Bonfire's IEx console:

```elixir
Bonfire.OpenID.Provider.ClientApps.get_or_new("My App", ["https://your-app.example/callback"])
```

This will return a JSON response with the client ID and secret.

### 3. Manage clients and scopes via IEx

For now you can use Bonfire's IEx console:

```elixir
# List all registered clients
Bonfire.OpenID.Provider.ClientApps.list_clients()

# List all available scopes
Bonfire.OpenID.Provider.ClientApps.list_scopes()

# List all active tokens
Bonfire.OpenID.Provider.ClientApps.list_active_tokens()
```

### 4. Configure the external app

Use the client ID and secret from step 2 to configure the client app you want to connect (and make sure it uses the redirect URI exactly as registered). An unregistered or mismatched redirect URI is refused, and no code is issued.

#### If the app speaks OpenID Connect

Most clients need only the issuer, which for a Bonfire instance is its base URL with no path:

```
https://your-bonfire-instance.tld
```

Clients that support discovery derive everything else from `<issuer>/.well-known/openid-configuration`. Some libraries want that full URL rather than deriving it, in which case give them the whole thing: `https://your-bonfire-instance.tld/.well-known/openid-configuration`.

Then set:

| Setting | Value |
|---|---|
| `client_id` / `client_secret` | from step 2 |
| `redirect_uri` | exactly as registered |
| `response_type` | `code` |
| `scope` | e.g. `openid email profile` |

#### If the app speaks plain OAuth2

Clients supporting RFC 8414 can instead read `/.well-known/oauth-authorization-server`, but some OAuth2 clients want each endpoint spelled out. Relative to the same base URL, these are:

| Setting | Path |
|---|---|
| authorize | `/oauth/authorize` |
| token | `/oauth/token` |
| userinfo | `/oauth/userinfo` |
| revoke | `/oauth/revoke` |
| introspect | `/oauth/introspect` |
| JWKS | `/openid/jwks` |

#### response_type vs grant_type

These are different fields and the values are not interchangeable, which is a common source of confusion:

- `response_type=code` goes on the request to `/oauth/authorize` or `/openid/authorize`.
- `grant_type=authorization_code` goes on the request to `/oauth/token` or `/openid/token`.

Valid response types here are `code`, `id_token`, `token`, `id_token token`, `code id_token`, `code token` and `code id_token token`. A grant type in the `response_type` field is rejected, though `authorization_code` and `implicit` are mapped to their response-type equivalents for the benefit of clients that send them.


### Provider endpoints

| Path                                 | Purpose                        |
|--------------------------------------|--------------------------------|
| `/oauth/revoke`                      | Provider: revoke token         |
| `/oauth/token`                       | Provider: token endpoint       |
| `/oauth/introspect`                  | Provider: introspect token     |
| `/oauth/authorize`                   | Provider: authorize endpoint   |
| `/oauth/ready`                       | Provider: readiness check      |
| `/openid/authorize`                  | Provider: OpenID authorize     |
| `/openid/userinfo`                   | Provider: user info endpoint   |
| `/openid/jwks`                       | Provider: JWKS endpoint        |
| `/openid/register`                   | Provider: dynamic client registration |
| `/.well-known/openid-configuration`  | Provider: OpenID Connect discovery |
| `/.well-known/oauth-authorization-server` | Provider: OAuth2 metadata (RFC 8414) |


---


## Supported Grant Types

Sent as `grant_type` on a request to the token endpoint, `/oauth/token` or `/openid/token`:

- `authorization_code`
- `implicit`
- `password`
- `client_credentials`
- `refresh_token`

Published in the discovery document as `grant_types_supported`.


## Supported Response Types

Sent as `response_type` on a request to the authorize endpoint, `/oauth/authorize` or `/openid/authorize`:

- `code`
- `id_token`
- `token`
- `id_token token`
- `code id_token`
- `code token`
- `code id_token token`

Published in the discovery document as `response_types_supported`.


## Redirect URIs

Must match what is registered for each client, exactly. Bonfire issues no code or token to an unregistered callback.


## Supported Scopes and Claims

- Standard scopes like `openid`, `email`, and `profile` are supported.
- No custom scopes or claims are defined by default.
- If you need custom claims, you can extend the `userinfo_fetched/2` function in `UserinfoController`.


## Troubleshooting

- **Login not working?** Double-check client IDs, secrets, and redirect URIs.
- **Provider not listed?** Make sure the relevant environment variables are set and the Bonfire instance has been restarted.
- **Callback errors?** Ensure the callback URL matches exactly between Bonfire and the provider’s configuration.
- **`Invalid response_type param`?** The client sent a grant type where a response type belongs. Use `response_type=code`, see [response_type vs grant_type](#response_type-vs-grant_type).
- **Client refuses to redirect, or reports the response type is unsupported?** Could be a similar mix-up, caught at the client end by comparing its configured response type against `response_types_supported` in the discovery document.
- **Unregistered redirect URI?** Register it first, via the `curl` or `iex` commands in step 2. Bonfire issues no code to an unregistered callback, by design.


---


## Copyright and License

Powered by these libraries: 
- [boruta](https://hex.pm/packages/boruta) (MIT)
- [openid_connect](https://hex.pm/packages/openid_connect) (MIT)

Extension copyright (c) 2022 Bonfire Contributors

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as
published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public
License along with this program.  If not, see <https://www.gnu.org/licenses/>.
