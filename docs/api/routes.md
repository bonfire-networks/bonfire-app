# API Routes Reference

Bonfire provides a Mastodon-compatible REST API, allowing you to use existing Mastodon clients and tools.

## OpenAPI Specification

OpenAPI specifications are available for client generation and tooling:

- [GoToSocial OpenAPI spec](https://docs.gotosocial.org/en/latest/api/swagger/)
- [Mastodon API documentation](https://docs.joinmastodon.org/api/)

## Coverage Summary

| Status | Count | Percentage |
|--------|-------|------------|
| **Implemented** | 53 | 23.6% |
| Not implemented | 160 | 71.1% |
| Errors/Issues | 12 | 5.3% |
| **Total** | 225 | 100% |

## Implemented Endpoints

The following endpoints are currently implemented and working:

### Instance & Discovery

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/.well-known/host-meta` | Host metadata (WebFinger) |
| GET | `/.well-known/nodeinfo` | NodeInfo discovery |
| GET | `/.well-known/webfinger` | WebFinger lookup |
| GET | `/nodeinfo/{version}` | NodeInfo details |
| GET | `/api/v1/instance` | Instance information |
| GET | `/api/v2/instance` | Instance information (v2) |
| GET | `/api/v1/custom_emojis` | Custom emoji list |

### Authentication & Accounts

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/accounts/verify_credentials` | Verify access token |
| GET | `/api/v1/accounts/relationships` | Get relationships with accounts |
| GET | `/api/v1/accounts/{id}` | Get account by ID |
| GET | `/api/v1/accounts/{id}/followers` | Get account's followers |
| GET | `/api/v1/accounts/{id}/following` | Get accounts followed by account |
| GET | `/api/v1/accounts/{id}/statuses` | Get account's statuses |
| POST | `/api/v1/accounts/{id}/mute` | Mute an account |
| POST | `/api/v1/accounts/{id}/unfollow` | Unfollow an account |
| GET | `/api/v1/preferences` | Get user preferences |

### Timelines

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/timelines/home` | Home timeline |
| GET | `/api/v1/timelines/public` | Public/federated timeline |
| GET | `/api/v1/timelines/list/{id}` | List timeline |
| GET | `/api/v1/timelines/tag/{tag}` | Hashtag timeline |

### Statuses

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/v1/statuses` | Create a status |
| GET | `/api/v1/statuses/{id}` | Get a status |
| DELETE | `/api/v1/statuses/{id}` | Delete a status |
| GET | `/api/v1/statuses/{id}/context` | Get status context (thread) |
| POST | `/api/v1/statuses/{id}/favourite` | Favourite a status |
| POST | `/api/v1/statuses/{id}/unfavourite` | Unfavourite a status |
| GET | `/api/v1/statuses/{id}/favourited_by` | Get accounts who favourited |
| POST | `/api/v1/statuses/{id}/reblog` | Reblog/boost a status |
| POST | `/api/v1/statuses/{id}/unreblog` | Unreblog/unboost a status |
| GET | `/api/v1/statuses/{id}/reblogged_by` | Get accounts who reblogged |
| POST | `/api/v1/statuses/{id}/unbookmark` | Remove status from bookmarks |

### Lists

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/lists` | Get all lists |
| POST | `/api/v1/lists` | Create a list |
| GET | `/api/v1/lists/{id}` | Get a list |
| PUT | `/api/v1/lists/{id}` | Update a list |
| POST | `/api/v1/lists/{id}/accounts` | Add accounts to list |
| DELETE | `/api/v1/lists/{id}/accounts` | Remove accounts from list |

### Media

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/media/{id}` | Get media attachment |
| PUT | `/api/v1/media/{id}` | Update media attachment |

### Notifications

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/notifications` | Get notifications |
| POST | `/api/v1/notifications/clear` | Clear all notifications |

### Social Features

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/bookmarks` | Get bookmarked statuses |
| GET | `/api/v1/favourites` | Get favourited statuses |
| GET | `/api/v1/conversations` | Get conversations (DMs) |
| GET | `/api/v1/mutes` | Get muted accounts |
| GET | `/api/v1/blocks` | Get blocked accounts |

### Follow Requests

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/follow_requests` | Get pending follow requests |
| GET | `/api/v1/follow_requests/outgoing` | Get outgoing requests |
| POST | `/api/v1/follow_requests/{id}/authorize` | Accept follow request |
| POST | `/api/v1/follow_requests/{id}/reject` | Reject follow request |

### Reports

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/reports` | Get submitted reports |
| POST | `/api/v1/reports` | Create a report |
| GET | `/api/v1/reports/{id}` | Get a specific report |

## Not Yet Implemented

The following categories have partial or no implementation yet:

### Coming Soon

- **Search** (`/api/v1/search`, `/api/v2/search`) - Account and status search
- **Filters** (`/api/v1/filters`, `/api/v2/filters`) - Content filtering
- **Polls** (`/api/v1/polls`) - Poll creation and voting
- **Scheduled Statuses** (`/api/v1/scheduled_statuses`) - Schedule posts
- **Markers** (`/api/v1/markers`) - Timeline position markers
- **Push Notifications** (`/api/v1/push/subscription`) - Web Push

### Admin Endpoints

Admin endpoints (`/api/v1/admin/*`) for instance administration are not yet implemented.

### Account Management

- `PATCH /api/v1/accounts/update_credentials` - Update account profile
- `POST /api/v1/accounts` - Account registration
- `DELETE /api/v1/profile/avatar` - Delete avatar
- `DELETE /api/v1/profile/header` - Delete header image

## Known Issues

Some endpoints have known issues being worked on:

| Endpoint | Issue |
|----------|-------|
| `GET /api/v1/accounts/lookup` | JSON encoding error |
| `GET /api/v1/accounts/search` | JSON encoding error |
| `POST /api/v1/accounts/{id}/follow` | Database transaction error |
| `POST /api/v1/apps` | OAuth client creation issue |

## Making Requests

### Authentication

Most endpoints require authentication. Include your access token in the `Authorization` header:

```bash
curl -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  "https://your-instance.example.org/api/v1/timelines/home"
```

See the [Authentication Guide](./authentication.md) for how to obtain tokens.

### Pagination

List endpoints support cursor-based pagination using Link headers:

```bash
curl -i "https://your-instance.example.org/api/v1/timelines/home?limit=20"
```

The response includes a `Link` header with `next` and `prev` URLs:

```
Link: <https://...?max_id=123>; rel="next", <https://...?min_id=456>; rel="prev"
```

Common pagination parameters:

| Parameter | Description |
|-----------|-------------|
| `limit` | Maximum number of results (default: 20, max: 40) |
| `max_id` | Return results older than this ID |
| `min_id` | Return results newer than this ID |
| `since_id` | Return results newer than this ID (inclusive) |

### Rate Limiting

The API implements rate limiting. When you exceed the limit, you'll receive a `429 Too Many Requests` response. Check the following headers:

| Header | Description |
|--------|-------------|
| `X-RateLimit-Limit` | Maximum requests allowed |
| `X-RateLimit-Remaining` | Requests remaining in window |
| `X-RateLimit-Reset` | When the limit resets (UTC) |

## See Also

- [Authentication Guide](./authentication.md) - How to authenticate with the API
- [Mastodon API Documentation](https://docs.joinmastodon.org/api/) - Original Mastodon API docs
