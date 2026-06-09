# Bonfire Groups & Topics — GraphQL API

Groups and topics are `Category` objects in the GraphQL schema, extended with group-specific fields and mutations. The schema is defined in `extensions/bonfire_classify/lib/graphql/schema.ex` and the resolvers in `extensions/bonfire_classify/lib/graphql/resolver.ex`.

All examples use the internal AbsintheClient mode (`use AbsintheClient, schema: Bonfire.API.GraphQL.Schema, action: [mode: :internal]`) as used by the REST adapter. The same queries work against the public `/api/graphql` endpoint.

---

## Queries

### `categories` — list groups/topics

```graphql
query {
  categories {
    edges {
      id
      name
      type
      members_count
      is_disabled
      parent_category_id
      boundaries { key slug label icon description }
      character { username }
    }
    page_info { has_next_page has_previous_page }
    total_count
  }
}
```

Arguments: `limit: Int`, `before: [Cursor!]`, `after: [Cursor!]` (standard page cursors).

> Client-side `type` filtering: the `categories` query returns all types. Filter by `type == "group"` / `"topic"` / `"label"` in the adapter — no server-side type arg exists yet.

### `category` — single group/topic by ID

```graphql
query($id: ID!) {
  category(category_id: $id) {
    id
    name
    type
    members_count
    is_disabled
    parent_category_id
    boundaries { key slug label icon description }
    character { username }
    members {
      entries {
        account { id profile { name } character { username } }
        relationship { member role following requested }
      }
      page_info { has_next_page }
    }
  }
}
```

Returns `null` when the ID doesn't exist or the current user can't read the group.

### `category.members` — paginated member list with roles

```graphql
query($id: ID!, $role: String) {
  category(category_id: $id) {
    members(role: $role, limit: 20, after: "cursor") {
      entries {
        account { id profile { name } character { username } }
        relationship { member role following requested }
      }
      page_info { has_next_page end_cursor }
    }
  }
}
```

`role` filter: `"member"`, `"moderator"`, or `"admin"`. Omit to return all members. Role is derived from the group's `tree.custodian_id` — the creator/custodian gets `"admin"`, everyone else `"member"`.

---

## Mutations

### `join_group`

```graphql
mutation($id: ID!) {
  join_group(group_id: $id) {
    member
    role
    following
    requested
  }
}
```

- Open group (`membership: "open"` or `"local:members"`): returns `member: true, following: true, requested: false`.
- Request-mode group (`membership: "on_request"`): returns `member: false, following: false, requested: true`.
- Invite-only group (`membership: "invite_only"`): returns an error.

### `leave_group`

```graphql
mutation($id: ID!) {
  leave_group(group_id: $id) {
    member
    role
    following
    requested
  }
}
```

Removes membership and unfollows in one call. Returns `member: false, following: false, requested: false`.

### `add_member` (admin only)

```graphql
mutation($gid: ID!, $uid: ID!) {
  add_member(group_id: $gid, account_id: $uid) {
    member
    role
    following
    requested
  }
}
```

Adds `account_id` directly as a member regardless of `join_mode`. Also used to add someone who has already sent a follow/join request. Returns 403 if the current user is not an admin of the group.

### `accept_join_request` (admin only)

```graphql
mutation($req: ID!) {
  accept_join_request(request_id: $req) {
    member
    role
    following
    requested
  }
}
```

Accepts a pending join request by its ID. Returns `member: true` on success. Returns 403 if the current user is not an admin.

### `remove_member` (admin only)

```graphql
mutation($gid: ID!, $uid: ID!) {
  remove_member(group_id: $gid, account_id: $uid)
}
```

Returns `true` on success (Boolean scalar). Returns 403 if the current user is not an admin.

### `create_category`

```graphql
mutation($name: String!, $type: String, $preset: String) {
  create_category(category: {
    name: $name
    type: $type
    boundary: { preset: $preset }
  }) {
    id
    name
    type
    boundaries { key slug }
    character { username }
  }
}
```

`type` defaults to `"group"`. `boundary.preset` is a named preset slug (e.g. `"open"`, `"private_club"`, `"on_request"`, `"invite_only"`). Omit `preset` to use the instance default. Available presets are discoverable via `boundaries(context: "group")`.

### `update_category`

```graphql
mutation($id: ID!, $name: String, $preset: String) {
  update_category(category_id: $id, category: {
    name: $name
    boundary: { preset: $preset }
  }) {
    id
    name
    type
    boundaries { key slug }
    character { username }
  }
}
```

Only the group admin may call this. Returns 403 otherwise.

---

## Types

### Extended `category` type

New fields on the existing `:category` object:

```graphql
type Category {
  # existing fields ...
  type: String        # "group" (default) | "topic" | "label"
  members_count: Int
  is_disabled: Boolean
  parent_category_id: ID

  # Resolved boundary dimensions — source of truth for group access rules.
  # `preset` is absent: it's write-only sugar; dimensions are the authority.
  # REST `join_mode` is derived from the "membership" entry here.
  boundaries: [BoundaryDimensionValue]
}

# Defined in bonfire_boundaries (extensions/bonfire_boundaries/lib/api/boundaries_api_graphql.ex)
# and imported into the classify schema.
type BoundaryDimensionValue {
  key: String!         # "membership" | "visibility" | "participation" | "default_content_visibility"
  slug: String!        # raw slug, e.g. "on_request", "local:discoverable"
  label: String        # display label from config, e.g. "Request to join"
  icon: String         # icon key, e.g. "ph:lock-duotone"
  description: String  # short description shown in UI
}
```

`BoundaryDimensionValue` resolvers read from `Config.get([:preset_dimensions, key, :options, slug], ...)` in `:bonfire_boundaries` — no DB query needed.

### `category_input` — 3-layer boundary model

Dimension keys and preset IDs are discovered via `GET /api/v1-bonfire/boundaries?context=group` — clients should not hardcode them.

```graphql
input CategoryInput {
  # existing fields ...
  type: String            # "group" (default) | "topic" | "label"
  boundary: BoundaryDimensionsInput # all access-rule changes grouped here
}

# Defined in bonfire_boundaries and imported into the classify schema.
input BoundaryDimensionsInput {
  # Layer 1 — pick a named preset (sets all 4 dimensions)
  preset: String          # slug from boundaries(context:"group").presets[].id

  # Layer 2 — binary overrides on top of the preset
  overrides: [KeyBooleanInput]

  # Layer 3 — raw per-dimension slugs (advanced; overrides preset + layer 2)
  dimensions: [KeyValueInput]
}
```

### Membership mutations

```graphql
join_group(group_id: ID!): GroupRelationship
leave_group(group_id: ID!): GroupRelationship
# Admin actions:
add_member(group_id: ID!, account_id: ID!): GroupRelationship   # direct add or existing follow request
accept_join_request(request_id: ID!): GroupRelationship          # accept a pending join request by request ID
remove_member(group_id: ID!, account_id: ID!): Boolean
```

### `Relationship` and `GroupRelationship` types

`Relationship` is defined in `extensions/bonfire_social_graph/lib/social_api_graphql.ex` for user-to-user relationships. `GroupRelationship` is defined in `extensions/bonfire_classify/lib/graphql/schema.ex` and returned by group membership mutations.

```graphql
# Define in bonfire_social_graph — covers user-to-user and user-to-group.
# No id field — Relationship is a computed state, not an entity; account_id is on the parent.
# Uses Bonfire's internal terminology; REST layer maps to Mastodon field names.
# Defined in bonfire_social or bonfire_me. subject = the account this is about.
# Privacy: ghosting/silencing null unless subject is the current user.
# REST: following→following, followed→followed_by, ghosting→blocking, silencing→muting
type Relationship {
  following: Boolean
  followed: Boolean
  ghosting: Boolean
  silencing: Boolean
  requested: Boolean
}

# Defined in bonfire_classify. Returned by join_group/leave_group/add_member.
# REST: standard Relationship + group extension field when target is a group.
type GroupRelationship {
  following: Boolean    # subscribed to group feed
  requested: Boolean    # pending join request
  member: Boolean!
  role: String          # "member" | "moderator" | "admin" | null
}
```

### Group membership — field resolvers on existing types

Rather than standalone queries, membership is resolved as fields on the relevant types:

```graphql
# On Category (group/topic):
type Category {
  # ... existing fields ...
  members(role: String, limit: Int, after: String): GroupMembersPage
}

type GroupMembersPage {
  entries: [GroupMemberEntry]
  page_info: PageInfo
}

type GroupMemberEntry {
  account: User
  relationship: GroupRelationship
}

# On User (their group memberships — resolver: CategoryResolver.user_groups/3):
type User {
  # ... existing fields ...
  groups(type: String): CategoriesPage   # type: "group" | "topic" | "label"
}
```

`GroupMembersPage.entries` is `[{ account: User, relationship: GroupRelationship }]`. The `user.groups` field is resolved by `Bonfire.Classify.my_followed_tree/2` and returns a flat list of top-level followed groups.

### `boundaries` query

```graphql
boundaries(context: String): Boundaries
```

`context` accepts `"post"` (default), `"user"`, `"group"`, `"instance"` (TODO), or any ULID.

```graphql
type Boundaries {
  context: String!
  visibility: [String]
  visibility_labels: [BoundaryLabelledOption]
  # Available interaction verbs — clients use these to build PolicyEntryInput lists.
  # Includes "request" as a first-class verb (granting "request" = can send an approval request).
  # Subject values are the same keywords as visibility (discovered via visibility_labels).
  verbs: [String]
  # Group boundary model — present when context=group or a group ULID
  presets: [BoundaryPreset]       # Layer 1
  overrides: [BoundaryOverrideOption]  # Layer 2
  dimensions: [BoundaryDimensionGroup] # Layer 3
}

# A named value with display metadata (shared by visibility_labels, policy_labels in REST)
type BoundaryLabelledOption {
  value: String!
  label: String!
  icon: String
  description: String
}

# Layer 1 — a named group preset bundling all 4 dimension slugs
type BoundaryPreset {
  id: String!
  label: String!
  description: String
  icon: String
  dimensions: [KeyValueEntry]  # dim name -> slug
  overrides_locked: [String]
}

# Layer 2 — a binary override switch
type BoundaryOverrideOption {
  key: String!
  label: String!
  help: String
}

# Layer 3 — a single dimension with its available options
type BoundaryDimensionGroup {
  key: String!           # e.g. "membership", "visibility"
  label: String!
  options: [BoundaryDimensionOption]
}

type BoundaryDimensionOption {
  value: String!
  label: String!
  icon: String
  description: String
  disabled: String       # null if available; reason string if disabled
}
```

Implementation reads `Config.get([:bonfire_boundaries, :preset_dimensions])`, `Config.get([:bonfire_classify, :group_presets])`, and `Config.get([:bonfire_classify, :layer2_toggles])` directly — no DB query needed.

### `create_post` / `update_post` mutation extensions

Mirrors the UI's layered boundary model: select a named preset, then optionally add per-verb grants on top.

```graphql
# Mirrors the internal %{verb => %{circle_id => :can/:cannot}} model.
# permission accepts any verb slug OR role name — both discoverable via boundaries.
input BoundaryPermissionInput {
  permission: String  # verb ("reply", "boost", "request", …) or role ("moderator", "member", …)
  can: [String]       # subject slugs (from boundaries.visibility_labels) or pointer IDs granted :can / assigned role
  cannot: [String]    # subjects explicitly denied (verb grants only)
}

# New top-level args on create_post / update_post:
#   context_id: ID          — post into a group, topic, or thread
#   boundary: String        — named preset ("public", "followers", etc.) → to_boundaries internally
#   permissions: [BoundaryPermissionInput]  — optional overrides on top of the preset → verb/role grant tuples internally
#
# REST translation: visibility → boundary, *_approval_policy params → permissions[].can, *_denied_policy → permissions[].cannot
```

Available verbs are discovered via `boundaries.verbs`. Includes `"see"`, `"read"`, `"reply"`, `"boost"`, `"like"`, `"quote"`, `"request"` (and others as configured).

REST → GraphQL mapping: `reply_approval_policy=followers` → `{permission: "reply", can: ["followers"]}`. `reply_denied_policy=nobody` → `{permission: "reply", cannot: ["nobody"]}`. `quote_manual_approval_policy=public` → `{permission: "request", can: ["public"]}`.

### `BoundaryPermission` type (on post responses)

GraphQL response mirrors the internal model. REST translates to Mastodon's `QuoteApproval` shape.

```graphql
# Mirrors BoundaryPermissionInput — one BoundaryPermission per permission (verb or role) on the post's ACL
type Subject {
  id: String!
  label: String   # resolved from boundaries config when this field is selected
}

type BoundaryPermission {
  permission: String!  # mirrors BoundaryPermissionInput.permission — verb slug or role name
  can: [Subject]       # mirrors BoundaryPermissionInput.can; Subject.label populated by resolver on demand
  cannot: [Subject]    # mirrors BoundaryPermissionInput.cannot
  current_user_grant: Boolean   # effective grant for the requesting user (true/false/null)
  # "manual" approval is expressed as a separate BoundaryPermission where permission = "request"
}
```

Added to post/activity response as `context: AnyContext` (union — query specific fields with inline fragments, e.g. `context { ... on Category { id } ... on Other { id } }`; resolver returns preloaded struct or a `%{id: context_id}` stub resolved as `:other` — no DB load when only the id is needed) and `permission_grants: [BoundaryPermission]`.

Resolver (`extensions/bonfire_social/lib/api/social_api_graphql.ex`) calls `Bonfire.Boundaries.VerbGrants.transform_to_verb_grants_format/1` on the post's ACL — the same logic as the UI boundary editor, moved to a shared context module. `Subject.label` is resolved from `boundaries.visibility_labels` config when the field is selected (no extra DB query).

REST serialises `permission_grants` into Mastodon `QuoteApproval`-shaped fields (`reply_approval`, `announce_approval`, `like_approval`, `quote_approval`): `can` → `automatic`, `cannot` → `denied`. The `manual` field in each approval object is derived from the `BoundaryPermission` where `permission = "request"`'s `can` list for the same interaction.
