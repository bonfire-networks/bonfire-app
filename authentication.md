# API Authentication

This guide walks you through authenticating with Bonfire's Mastodon-compatible API using OAuth 2.0.

## Overview

Bonfire implements OAuth 2.0 for API authentication, compatible with Mastodon clients. The flow involves:

1. Creating an application
2. Authorizing the application to act on your behalf
3. Exchanging the authorization code for an access token
4. Using the token to make authenticated API requests

## Prerequisites

- A Bonfire instance (e.g., `https://bonfire.example.org`)
- A user account on that instance
- `curl` or similar HTTP client

Replace `bonfire.example.org` with your instance's domain in all examples below.

## Step 1: Create an Application

First, register your application with the Bonfire instance:

```bash
curl -X POST \
  -H "Content-Type: application/json" \
  -d '{
    "client_name": "My Application",
    "redirect_uris": "urn:ietf:wg:oauth:2.0:oob",
    "scopes": "read write",
    "website": "https://myapp.example.com"
  }' \
  "https://bonfire.example.org/api/v1/apps"
```

Response:

```json
{
  "id": "your-client-id",
  "name": "My Application",
  "client_id": "your-client-id",
  "client_secret": "your-client-secret",
  "redirect_uri": "urn:ietf:wg:oauth:2.0:oob",
  "website": "https://myapp.example.com"
}
```

> **Important**: Save the `client_id` and `client_secret` securely. The secret will only be shown once.

### Scopes

Request only the scopes your application needs (principle of least privilege):

| Scope | Description |
|-------|-------------|
| `read` | Read account data |
| `read:accounts` | Read account information |
| `read:blocks` | Read blocked accounts |
| `read:bookmarks` | Read bookmarked statuses |
| `read:favourites` | Read favourited statuses |
| `read:filters` | Read filters |
| `read:follows` | Read follow relationships |
| `read:lists` | Read lists |
| `read:mutes` | Read muted accounts |
| `read:notifications` | Read notifications |
| `read:search` | Perform searches |
| `read:statuses` | Read statuses |
| `write` | Write account data |
| `write:accounts` | Modify account information |
| `write:blocks` | Block/unblock accounts |
| `write:bookmarks` | Bookmark/unbookmark statuses |
| `write:conversations` | Manage conversations |
| `write:favourites` | Favourite/unfavourite statuses |
| `write:filters` | Manage filters |
| `write:follows` | Follow/unfollow accounts |
| `write:lists` | Manage lists |
| `write:media` | Upload media |
| `write:mutes` | Mute/unmute accounts |
| `write:notifications` | Manage notifications |
| `write:reports` | Submit reports |
| `write:statuses` | Create/delete statuses |
| `follow` | Manage follows (legacy) |
| `push` | Receive push notifications |

Admin scopes (`admin:read`, `admin:write`, etc.) are also available for admin accounts.

## Step 2: Authorize the Application

Open the following URL in a web browser (replace the values with your own):

```
https://bonfire.example.org/oauth/authorize?client_id=YOUR_CLIENT_ID&redirect_uri=urn:ietf:wg:oauth:2.0:oob&response_type=code&scope=read+write
```

Or construct it programmatically:

```bash
CLIENT_ID="your-client-id"
REDIRECT_URI="urn:ietf:wg:oauth:2.0:oob"
SCOPE="read write"

echo "https://bonfire.example.org/oauth/authorize?client_id=${CLIENT_ID}&redirect_uri=${REDIRECT_URI}&response_type=code&scope=${SCOPE// /+}"
```

This will:

1. Prompt the user to log in (if not already logged in)
2. Show the requested permissions
3. After approval, display an authorization code (out-of-band)

Copy the authorization code displayed.

## Step 3: Exchange Code for Access Token

Exchange the authorization code for an access token:

```bash
curl -X POST \
  -H "Content-Type: application/json" \
  -d '{
    "client_id": "your-client-id",
    "client_secret": "your-client-secret",
    "redirect_uri": "urn:ietf:wg:oauth:2.0:oob",
    "grant_type": "authorization_code",
    "code": "authorization-code-from-step-2"
  }' \
  "https://bonfire.example.org/oauth/token"
```

Response:

```json
{
  "access_token": "your-access-token",
  "token_type": "Bearer",
  "expires_in": 86400,
  "refresh_token": "your-refresh-token",
  "scope": "read write",
  "created_at": 1234567890
}
```

## Step 4: Verify Your Token

Test that your token works by fetching your account information:

```bash
curl -H "Authorization: Bearer your-access-token" \
  "https://bonfire.example.org/api/v1/accounts/verify_credentials"
```

Response:

```json
{
  "id": "01ABC...",
  "username": "yourname",
  "acct": "yourname",
  "display_name": "Your Name",
  "locked": false,
  "bot": false,
  "created_at": "2024-01-01T00:00:00.000Z",
  ...
}
```

## Using the Access Token

Include the token in all subsequent API requests:

```bash
# Get your home timeline
curl -H "Authorization: Bearer your-access-token" \
  "https://bonfire.example.org/api/v1/timelines/home"

# Post a status
curl -X POST \
  -H "Authorization: Bearer your-access-token" \
  -H "Content-Type: application/json" \
  -d '{"status": "Hello from the API!"}' \
  "https://bonfire.example.org/api/v1/statuses"

# Get notifications
curl -H "Authorization: Bearer your-access-token" \
  "https://bonfire.example.org/api/v1/notifications"
```

## Refreshing Tokens

When your access token expires, use the refresh token to get a new one:

```bash
curl -X POST \
  -H "Content-Type: application/json" \
  -d '{
    "client_id": "your-client-id",
    "client_secret": "your-client-secret",
    "grant_type": "refresh_token",
    "refresh_token": "your-refresh-token"
  }' \
  "https://bonfire.example.org/oauth/token"
```

## Revoking Tokens

When a user logs out or you no longer need access, revoke the token:

```bash
curl -X POST \
  -H "Content-Type: application/json" \
  -d '{
    "client_id": "your-client-id",
    "client_secret": "your-client-secret",
    "token": "your-access-token"
  }' \
  "https://bonfire.example.org/oauth/revoke"
```

## Token Introspection

Check if a token is valid and get its metadata:

```bash
curl -X POST \
  -H "Content-Type: application/json" \
  -d '{
    "client_id": "your-client-id",
    "client_secret": "your-client-secret",
    "token": "your-access-token"
  }' \
  "https://bonfire.example.org/oauth/introspect"
```

Response:

```json
{
  "active": true,
  "scope": "read write",
  "client_id": "your-client-id",
  "username": "yourname",
  "exp": 1234567890
}
```

## OpenID Connect

Bonfire also supports OpenID Connect for single sign-on. Key endpoints:

| Endpoint | Description |
|----------|-------------|
| `/.well-known/openid-configuration` | OpenID configuration discovery |
| `/openid/authorize` | OpenID authorization |
| `/openid/token` | OpenID token endpoint |
| `/openid/jwks` | JSON Web Key Set |
| `/openid/userinfo` | User information |
| `/openid/register` | Dynamic client registration |

## Error Handling

Common error responses:

| Status | Error | Description |
|--------|-------|-------------|
| 400 | `invalid_request` | Missing or invalid parameters |
| 401 | `invalid_token` | Token is expired or invalid |
| 401 | `unauthorized_client` | Client not authorized for this grant type |
| 403 | `insufficient_scope` | Token doesn't have required scope |

## Security Best Practices

1. **Store secrets securely**: Never expose `client_secret` or tokens in client-side code
2. **Use HTTPS**: Always use HTTPS for all API requests
3. **Minimal scopes**: Request only the scopes you actually need
4. **Token rotation**: Regularly refresh tokens and revoke unused ones
5. **Validate tokens**: Check token validity before making requests

## See Also

- [API Routes Reference](./routes.md) - Full list of available API endpoints
