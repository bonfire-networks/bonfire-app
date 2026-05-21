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

**Query parameters:**

| Param | Type | Default | Description |
|---|---|---|---|
| `role` | `"member" \| "moderator" \| "admin"` | — | Filter by role. Omit to return all members. Use `?role=moderator` or `?role=admin` to list moderators/admins. |
| `max_id`, `since_id`, `min_id`, `limit` | — | — | Standard pagination |

**Response:** `200 OK` — `Array<{ account: Account, relationship: Relationship }>`. Each entry pairs the standard Account object with its Relationship so `relationship.group.role` is consistent with every other endpoint that returns Relationships.

```json
[
  {
    "account": {
      "id": "01JPXYZ...",
      "username": "alice",
      "acct": "alice@social.example",
      "display_name": "Alice"
    },
    "relationship": {
      "id": "01JPXYZ...",
      "following": true,
      "group": {
        "member": true,
        "role": "admin"
      }
    }
  }
]
```

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

## Posting a Status — Extension Parameters

The standard `POST /api/v1/statuses` accepts the following additional parameters.

### Context

| Param | Type | Description |
|---|---|---|
| `context_id` | string | ULID of the context this post belongs to — a group/topic Account, a thread root Status, or any other container. Bonfire routes it accordingly (e.g. boosts the post into a group's feed). Complements `in_reply_to_id`: use `in_reply_to_id` to reply to a specific post, `context_id` to post *within* a context. |

### Visibility

`visibility` works exactly as Mastodon defines it (i.e. sets the visibility of the posted status to public, unlisted, private, or direct), but Bonfire provides extra visibility options, and the defaults can also be extended by each user or group, so you can use `GET /api/v1-bonfire/boundaries` to get options available for the authenticated user (eg. for a new post).

> In a later version: You can also use `GET /api/v1-bonfire/boundaries?context=<post|user|instance|group>` to get possible options for different contexts. 

When posting a status with `context_id` being a group, it is recommended to omit `visibility` so it will use the group's configured default. 

> In a later version: If provided along with `context_id`, it must be a value permitted by the group — use `GET /api/v1-bonfire/boundaries?context=<group_id>` to discover what is allowed for that group before composing.

### Interaction policies

Modeled after Mastodon's `quote_approval_policy` field and `QuoteApproval` entity. Each interaction has policy fields controlling automatic approval, manual approval (request where supported), and explicit denial. When `context_id` is a group, omit all policy fields to use the group's configured defaults. Ignored when `visibility` is `direct`.

The available policies and their permitted values depend on the context — use `GET /api/v1-bonfire/boundaries?context=...` to discover what applies before composing. The params listed below are the known set; not all are supported in every context:

| Param | Type | Description |
|---|---|---|
| `reply_approval_policy` | String (Enumerable, oneOf) | Who may reply without requiring approval. `members` restricts to members of the `context_id` group. |
| `reply_denied_policy` | Same format as `_approval_policy` (keywords or account IDs) | Who is explicitly denied from replying regardless of `reply_approval_policy`. |
| `announce_approval_policy` | String (Enumerable, oneOf) | Who may boost without requiring approval. |
| `announce_denied_policy` | Same format as `_approval_policy` (keywords or account IDs) | Who is explicitly denied from boosting. |
| `like_approval_policy` | String (Enumerable, oneOf) | Who may react. |
| `like_denied_policy` | Same format as `_approval_policy` (keywords or account IDs) | Who is explicitly denied from reacting. |
| `quote_approval_policy` | String (Enumerable, oneOf) | Standard Mastodon field — who may quote without requiring approval. |
| `quote_manual_approval_policy` | String (Enumerable, oneOf) | Who may quote subject to author's manual approval. |
| `quote_denied_policy` | Same format as `_approval_policy` (keywords or account IDs) | Who is explicitly denied from quoting. |

All field types accept the same value format: one or more keywords or account IDs. Available keywords are provided by `GET /api/v1-bonfire/boundaries` as they can be extended by the server or group. In a future version, circle IDs will also be supported.


### The `Status` object — extension fields

Extension fields present on Status responses when applicable. The `*_approval` objects follow the same shape as Mastodon's `QuoteApproval` entity, extended to all interaction types.

```json
{
  "context_id": "01JPXYZ...",
  "context_type": "group",
  "quote_approval": {
    "automatic": ["followers"],
    "manual": ["public"],
    "current_user": "automatic"
  },
  "reply_approval": {
    "automatic": ["followers", "mentioned"],
    "manual": ["public"],
    "current_user": "denied"
  },
  "announce_approval": {
    "automatic": ["followers"],
    "manual": [],
    "current_user": "manual"
  },
  "like_approval": {
    "automatic": ["public"],
    "current_user": "automatic"
  }
}
```

| Field | Type | Description |
|---|---|---|
| `context_id` | string \| null | ULID of the context this status was posted into |
| `context_type` | `"group" \| "topic" \| "thread"` \| null | Type of the context object, so clients don't need to resolve `context_id` to know what kind of thing it is |
| `quote_approval` | QuoteApproval \| null | Standard Mastodon `QuoteApproval` entity — who may quote and how it applies to the requesting user |
| `reply_approval` | QuoteApproval \| null | Same shape as `QuoteApproval` — who may reply and the requesting user's effective permission |
| `announce_approval` | QuoteApproval \| null | Same shape — who may boost. No `manual` field as request-based approval is not supported for boosts |
| `like_approval` | QuoteApproval \| null | Same shape — who may react. No `manual` field |

`current_user` on each approval object is one of `"automatic"`, `"manual"`, `"denied"`, or `"unknown"`.

---

## Boundaries Discovery

### `GET /api/v1-bonfire/boundaries`

Returns the visibility presets and available interaction policy options for the given context. Clients use this to build a compose UI with the correct visibility picker and policy selectors.

**Authentication:** required

**Query parameters:**

| Param | Type | Default | Description |
|---|---|---|---|
| `context` | `"instance" \| "user"` or a ULID | `"user"` | The context to return valid options for. Pass `"user"` for a regular post, `"instance"` for server-wide policies, or a group/topic ULID to get the options permitted within that specific group. |

Examples:
- `GET /api/v1-bonfire/boundaries` — options for a regular post
- `GET /api/v1-bonfire/boundaries?context=instance` — instance-level policies (TODO in a later version)
- `GET /api/v1-bonfire/boundaries?context=01JPXYZ...` — options permitted when posting into that group or topic (TODO in a later version)

**Response:** `200 OK`

```json
{
  "context": "01JPXYZ...",
  "visibility": ["public", "unlisted", "private"],
  "visibility_labels": {
    "public":   {"label": "Public",      "icon": "globe",    "description": "Visible to everyone"},
    "unlisted": {"label": "Local only",  "icon": "home",     "description": "Visible to users on this instance"},
    "private":  {"label": "Followers",   "icon": "lock",     "description": "Visible to your followers only"},
    "direct":   {"label": "Direct",      "icon": "envelope", "description": "Visible to mentioned users only"}
  },
  "policies": {
    "reply_approval_policy":        ["public", "followers", "members", "mentioned", "nobody"],
    "reply_denied_policy":          ["public", "followers", "members", "mentioned", "nobody"],
    "announce_approval_policy":     ["public", "followers", "members", "nobody"],
    "announce_denied_policy":       ["public", "followers", "members", "nobody"],
    "like_approval_policy":         ["public", "followers", "members", "nobody"],
    "like_denied_policy":           ["public", "followers", "members", "nobody"],
    "quote_approval_policy":        ["public", "followers", "nobody"],
    "quote_manual_approval_policy": ["public", "followers", "members", "nobody"],
    "quote_denied_policy":          ["public", "followers", "members", "nobody"]
  },
  "policy_labels": {
    "public":    {"label": "Anyone",         "icon": "globe",    "description": "Anyone can interact"},
    "followers": {"label": "Followers",      "icon": "lock",     "description": "Only your followers"},
    "members":   {"label": "Group members",  "icon": "people",   "description": "Only members of this group"},
    "mentioned": {"label": "Mentioned only", "icon": "at",       "description": "Only accounts you mention"},
    "nobody":    {"label": "Nobody",         "icon": "block",    "description": "Disabled"}
  }
}
```

| Field | Type | Description |
|---|---|---|
| `context` | string | Echoes back the resolved context |
| `visibility` | array of strings | Visibility values permitted in this context. Pass the chosen value as the standard `visibility` param on `POST /api/v1/statuses`. |
| `visibility_labels` | object | Display metadata for each visibility value — `label`, `icon` (semantic name, map to your own icon set), and `description`, all localised by the server. |
| `policies` | object | Keyed by the param name to use on `POST /api/v1/statuses`. Each value is an array of permitted option keys. Only policies applicable to the context are included — treat this as the authoritative list. `"members"` only appears when `context` is a group or topic ULID. |
| `policy_labels` | object | Display metadata for policy keyword values — `label`, `icon` (semantic name), and `description`, all localised by the server. Clients should look up display strings here rather than hardcoding them. |

---

## Dedicate endpoints NOT needed (use standard Mastodon API)

| Need | Standard endpoint |
|---|---|
| Get a group's posts/feed | `GET /api/v1/accounts/:id/statuses` |
| Check membership / role | `GET /api/v1/accounts/relationships?id[]=:group_id` — see `group.member` and `group.role` |
| Follow group feed (without joining, only works if allowed by group boundaries) | `POST /api/v1/accounts/:id/follow` — sets `following: true`, does not affect `group.member` |
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
