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
OPENID_1_DISCOVERY=https://yourprovider.example/.well-known/openid-configuration
OPENID_1_CLIENT_ID=your-client-id
OPENID_1_CLIENT_SECRET=your-client-secret
OPENID_1_DISPLAY_NAME=Your Provider Name
OPENID_1_SCOPE=openid email profile
OPENID_1_ENABLE_SIGNUP=false
```

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

- In your client app, set the Bonfire instance as the OpenID Connect or OAuth2 provider.
- Use the client ID and secret generated in step 2.
- Make sure the redirect URIs matches what you registered.


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
| `/.well-known/openid-configuration`  | Provider: discovery endpoint   |


---


## Supported Grant Types

Bonfire should support all standard OAuth2 and OpenID Connect grant types:

- Authorization Code
- Implicit
- Hybrid
- Client Credentials
- Resource Owner Password Credentials

Redirect URIs must match what is registered for each client.


## Supported Scopes and Claims

- Standard scopes like `openid`, `email`, and `profile` are supported.
- No custom scopes or claims are defined by default.
- If you need custom claims, you can extend the `userinfo_fetched/2` function in `UserinfoController`.


## Troubleshooting

- **Login not working?** Double-check client IDs, secrets, and redirect URIs.
- **Provider not listed?** Make sure the relevant environment variables are set and the Bonfire instance has been restarted.
- **Callback errors?** Ensure the callback URL matches exactly between Bonfire and the provider’s configuration.


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
