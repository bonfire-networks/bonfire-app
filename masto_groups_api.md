# Mastodon-Compatible Groups & Topics API

Draft extension of the standard Mastodon REST API for Bonfire groups and topics.

All new endpoints live under `/api/v1-bonfire/` to distinguish them from the standard Mastodon v1/v2 API.

---

## Design Principles

- **Groups are Accounts.** A Bonfire `Category` with `type: :group` or `type: :topic` is an ActivityPub actor and is served as a standard Mastodon `Account` object. This means groups can appear as the `account` (creator/subject) on a `Status` or any other activity without special-casing on the client. `Account.display_name` maps to `Category.name`; `Account.note` maps to `Category.summary`.
- **`group` is an extension field.** Just as `Event` extends `Status` by adding an `event` field, `Group` extends `Account` by adding a `group` field. The `group` field only contains fields that don't already exist on `Account`.
- **IDs are shared.** The group's `Account.id` is the same ULID as the underlying `Category`. Bonfire resolves IDs through our pointer table, so the same ID routes correctly to the category schema without any prefix.
- **Depth is opt-in.** Full nested `sub_groups` and `parent_group` objects are not included by default. Callers request them via depth params. A flat `parent_group_id` is always present.
- **Follow and membership are partially decoupled.** Following a group subscribes to its feed in the home timeline. Membership grants access rights (posting, private content). Joining automatically follows, and leaving automatically unfollows, but each can be adjusted independently afterwards.
- **Group timeline = account statuses.** Since a group is an account with the same ID, use the standard `GET /api/v1/accounts/:id/statuses` to fetch its feed. No duplicate endpoint needed.

---

## The `group` Extension Object

Attached to any `Account` that represents a group or topic as `account.group`.
Fields already present on `Account` are not duplicated here (`name` → `display_name`, `summary` → `note`, `canonical_url` → `url`, `username` → `username`).

```json
{
  "type": "group",
  "join_mode": "free",
  "members_count": 0,
  "is_disabled": false,
  "extra_info": null,
  "parent_group_id": null,
  "parent_group": null,
  "sub_groups": []
}
```

| Field | Type | Always present | Description |
|---|---|---|---|
| `type` | `"group" \| "topic" \| "label"` | yes | Maps to `Bonfire.Classify.Category.type` |
| `join_mode` | `"free" \| "request" \| "invite"` | yes | How new members join. Also reflected on `Account.locked` (`locked: true` when not `"free"`) |
| `members_count` | integer | yes | Number of members. Distinct from `Account.followers_count` when follow/membership are decoupled |
| `is_disabled` | boolean | yes | Whether the group has been soft-disabled. Maps to `Category.is_disabled` |
| `extra_info` | object \| null | yes | Freeform JSON metadata. Maps to `Category` `ExtraInfo` mixin |
| `parent_group_id` | string \| null | yes | ULID of the parent category. Always present without requiring a depth param |
| `parent_group` | Account \| null | conditional | Full parent Account with its own `group` field. Only populated when `?parent_depth >= 1` |
| `sub_groups` | Array\<Account\> | conditional | Direct child Accounts, each with their own `group` field. Only populated when `?sub_depth >= 1`. Empty array otherwise |

### Example — full Account with `group` extension

```json
{
  "id": "01JPXYZ...",
  "username": "cooking",
  "acct": "cooking@social.example",
  "display_name": "Cooking",
  "note": "<p>All things food and drink.</p>",
  "url": "https://social.example/@cooking",
  "uri": "https://social.example/groups/cooking",
  "avatar": "https://social.example/media/cooking-avatar.jpg",
  "avatar_static": "https://social.example/media/cooking-avatar.jpg",
  "header": "https://social.example/media/cooking-header.jpg",
  "header_static": "https://social.example/media/cooking-header.jpg",
  "locked": false,
  "created_at": "2024-01-15T10:00:00.000Z",
  "followers_count": 128,
  "following_count": 0,
  "statuses_count": 342,
  "emojis": [],
  "fields": [],
  "group": {
    "type": "group",
    "join_mode": "free",
    "is_disabled": false,
    "extra_info": null,
    "parent_group_id": null,
    "parent_group": null,
    "sub_groups": [
      {
        "id": "01JPXYZ...",
        "username": "baking",
        "acct": "baking@social.example",
        "display_name": "Baking",
        "note": "<p>Bread, pastry, and everything baked.</p>",
        "url": "https://social.example/@baking",
        "locked": false,
        "group": {
          "type": "topic",
          "join_mode": "free",
          "is_disabled": false,
          "extra_info": null,
          "parent_group_id": "01JPXYZ...",
          "parent_group": null,
          "sub_groups": []
        }
      }
    ]
  }
}
```

---

## Endpoints

### `GET /api/v1-bonfire/groups`

List groups (and optionally topics/labels).

**Authentication:** optional (public groups visible to all; private groups only to members)

**Query parameters:**

| Param | Type | Default | Description |
|---|---|---|---|
| `type` | `"group" \| "topic" \| "label"` | `"group"` | Filter by category type |
| `top_level` | boolean | `true` | When `true`, only return root groups (no parent). Mutually exclusive with `parent_id` |
| `parent_id` | string | — | Only return direct children of this group/topic |
| `sub_depth` | integer | `0` | How many levels of `sub_groups` to nest (0 = empty array). Use with `top_level=true` to get a tree: `?top_level=true&sub_depth=2` returns roots with 2 levels of children embedded |
| `parent_depth` | integer | `0` | How many ancestor levels to include on `parent_group` (0 = null) |
| `max_id` | string | — | Return results older than this ID |
| `since_id` | string | — | Return results newer than this ID |
| `min_id` | string | — | Return results immediately newer than this ID |
| `limit` | integer | `20` | Max results (max: `80`) |

**Response:** `200 OK` — `Array<Account>` (each with `group` field)
Includes `Link` header for pagination (same RFC 5988 format as Mastodon timelines).

---

### `GET /api/v1-bonfire/groups/:id`

Get a single group or topic by ID (ULID) or username.

**Authentication:** optional

**Query parameters:**

| Param | Type | Default | Description |
|---|---|---|---|
| `sub_depth` | integer | `1` | Levels of sub-groups to nest |
| `parent_depth` | integer | `1` | Levels of parent chain to include |

**Response:**
- `200 OK` — `Account` with `group` field
- `404 Not Found` — not found or not readable by current user

---

### `GET /api/v1-bonfire/groups/:id/members`

List members of a group.

**Authentication:** optional (may require membership for private groups)

**Query parameters:** `max_id`, `since_id`, `min_id`, `limit`

**Response:** `200 OK` — `Array<Account>` (standard Mastodon Account objects, no `group` field)
Includes `Link` header for pagination.

---

### `GET /api/v1-bonfire/accounts/:id/groups`

List groups that an account is a member of.

**Authentication:** optional

**Query parameters:**

| Param | Type | Default | Description |
|---|---|---|---|
| `type` | `"group" \| "topic" \| "label"` | — | Filter by type (all types returned if omitted) |
| `sub_depth` | integer | `0` | Levels of sub-groups to nest |
| `parent_depth` | integer | `0` | Levels of parent chain to include |
| `max_id`, `since_id`, `min_id`, `limit` | — | — | Standard pagination |

**Response:** `200 OK` — `Array<Account>` (each with `group` field)
Includes `Link` header for pagination.

---

## Extended Relationship Object

When `GET /api/v1/accounts/relationships?id[]=:group_id` is called for an account that is a group, the standard Mastodon `Relationship` object gains an extra `group` field. `following` retains its standard meaning (subscribed to the group's posts in home feed) and is independent from `group.member`.

```json
{
  "id": "01JPXYZ...",
  "following": true,
  "showing_reblogs": true,
  "notifying": false,
  "followed_by": false,
  "blocking": false,
  "muting": false,
  "requested": false,
  "note": "",
  "group": {
    "member": true,
    "role": "member"
  }
}
```

| Field | Type | Description |
|---|---|---|
| `requested` | boolean | Standard Mastodon field. For groups with `join_mode: "request"`, `true` means a join request is pending approval — same semantics as a follow request on a locked account |
| `group.member` | boolean | Whether the current user is a member, regardless of follow state |
| `group.role` | `"member" \| "moderator" \| "admin"` \| null | Current user's role within the group. `null` if not a member |

No new endpoint needed — this is purely an extension of the existing relationships response.

---

### `POST /api/v1-bonfire/groups/:id/join`

Join a group, or request to join if `join_mode` is `"request"`.

**Authentication:** required

**Response:** `200 OK` — updated `Relationship`

If `join_mode` is `"free"`:
```json
{
  "id": "01JPXYZ...",
  "following": true,
  "requested": false,
  ...
  "group": {
    "member": true,
    "role": "member"
  }
}
```

If `join_mode` is `"request"` (pending approval):
```json
{
  "id": "01JPXYZ...",
  "following": false,
  "requested": true,
  ...
  "group": {
    "member": false,
    "role": null
  }
}
```

Note: Joining with `join_mode: "free"` also automatically sets `following: true`. The user can later unfollow the group feed without leaving by calling `POST /api/v1/accounts/:id/unfollow`.

**Error responses:**
- `404 Not Found` — group does not exist or is not visible to current user

---

### `POST /api/v1-bonfire/groups/:id/leave`

Leave a group, or cancel a pending join request.

**Authentication:** required

**Response:** `200 OK` — updated `Relationship`

```json
{
  "id": "01JPXYZ...",
  "following": false,
  "requested": false,
  ...
  "group": {
    "member": false,
    "role": null
  }
}
```

Note: Leaving also automatically sets `following: false`. The user can later re-follow the group feed without rejoining (if posts are visible to non-members) by calling `POST /api/v1/accounts/:id/follow`.

**Error responses:**
- `404 Not Found` — group does not exist or is not visible to current user

---

## Endpoints NOT needed (use standard Mastodon API)

| Need | Standard endpoint |
|---|---|
| Get a group's posts/feed | `GET /api/v1/accounts/:id/statuses` |
| Check membership / role | `GET /api/v1/accounts/relationships?id[]=:group_id` — see `group.member` and `group.role` |
| Follow group feed (without joining) | `POST /api/v1/accounts/:id/follow` — sets `following: true`, does not affect `group.member` |
| Unfollow group feed (without leaving) | `POST /api/v1/accounts/:id/unfollow` — sets `following: false`, does not affect `group.member` |

---

## Notes on Depth Parameters

`sub_depth=N` and `parent_depth=N` control recursive nesting. `parent_group_id` is always present regardless.

- `0` — full object omitted (`sub_groups: []`, `parent_group: null`)
- `1` — one level: direct children / immediate parent
- `2` — two levels: children of children / parent and grandparent
- etc.

List endpoints (`GET /groups`) default both to `0` to keep responses lean.
Single-item endpoints (`GET /groups/:id`) default both to `1`.
