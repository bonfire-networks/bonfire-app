# Group Boundary Model — 4 Dimensions

> **Note:** The authoritative source for current dimension slugs, labels, and icons is `extensions/bonfire_boundaries/lib/runtime_config.ex` (`preset_dimensions`) and `extensions/bonfire_classify/lib/runtime_config.ex` (`group_presets`, `layer2_toggles`). The `GET /api/v1-bonfire/boundaries?context=group` endpoint exposes this config at runtime. This document is background reference only.

Groups have four independent boundary dimensions. Each has a small set of meaningful options. Picking a named preset (Layer 1) sets all four at once; Layer 2 toggles and Layer 3 raw dimension values override individual axes.

## Scopes

Three of the four dimensions are organised by **scope** — how far the group reaches — and the scope names recur across them:

| Scope | Means | Marked `disabled` in config |
|-------|-------|------------------------------|
| `global` | The whole fediverse | yes, until groups federation ships |
| `archipelago` | Trusted linked instances | yes, until the archipelago feature ships |
| `nonfederated` | Everyone on this instance, including guests, sent nowhere | no |
| `local` | Logged-in users of this instance | no |
| `members` | The group's own members | no |

`Bonfire.Boundaries.Presets.slug_scope/1` reads the part before the first `:`, falling back to `global` for a prefix that is not a known scope — which is why `anyone`, `discoverable`, `unlisted` and `public` all resolve to the `global` scope despite not being spelled that way.

**Membership and participation have no `nonfederated` slug**, and this is deliberate rather than a gap: a group that federates nothing has only local users to be joined by or posted in by. So the *participant* scope of a `nonfederated` group is `local` (`participant_scope_for/1` in `Bonfire.Classify.Boundaries`).

---

## 1. Membership — who can join

| Slug | Scope | Meaning |
|------|-------|---------|
| `open` | `global` | Anyone can join freely, including remote users |
| `archipelago:members` | `archipelago` | Anyone on a trusted linked instance can join *(not yet implemented)* |
| `local:members` | `local` | Anyone on this instance can join freely |
| `on_request` | — | Anyone can request to join; a moderator approves |
| `invite_only` | — | Only moderators can add members (no join/request button shown) |

The first three are the *free to join* slugs, distinguished by scope; the last two are process-based and scope-independent.

## 2. Group visibility — who can see the group and its content (`:see` / `:read` verbs)

Laid out as a scope × role grid. The role is how MUCH the audience gets: `:interact` (see + read + interact), `:discover` (see it exists, members-only content), `:unlisted_read` (readable by direct link, not listed).

| Scope | `:interact` | `:discover` | `:unlisted_read` |
|-------|-------------|-------------|------------------|
| `global` | `global` | `discoverable` | `unlisted` |
| `archipelago` | `archipelago` | `archipelago:discoverable` | `archipelago:unlisted` |
| `nonfederated` | `nonfederated` | `nonfederated:discoverable` | `nonfederated:unlisted` |
| `local` | `local` | `local:discoverable` | `local:unlisted` |
| `members` | `members:private` | — | — |

Only the bare `archipelago` slug appears in the dimension's `slug_order`; its `:discoverable` / `:unlisted` variants exist in `:preset_acls` but are not yet selectable.

## 3. Participation — who can post/interact (`:create`, `:reply`, `:boost`, `:like` verbs)

| Slug | Scope | Meaning |
|------|-------|---------|
| `anyone` | `global` | Any user anywhere, including remote |
| `archipelago:contributors` | `archipelago` | Users on trusted linked instances *(not yet implemented)* |
| `local:contributors` | `local` | Any local user |
| `group_members` | — | Members only (default) |
| `moderators` | — | Moderators only; members can read and react but not post |

The first three admit **non-members**, differing only in which population; the last two are member-list based. `group_members` and `moderators` are circle-controlled and carry no ACL signature, so `group_dimension_slugs/1` reads them back as `nil` — which is why `preset_slug_from_dims/1` falls back to matching on `(membership, visibility)` alone, and why **two presets must not share that pair**.

Participation slugs carry no `role`, unlike visibility and DCV.

## 4. Default content visibility — how posts in this group are shared by default

Same scope × role grid as visibility, except the `global` scope is spelled `public*`. Stored per group in settings; pre-fills the composer's boundary selector via `read_default_content_visibility/2`, and authors can still change it. Affects future posts only.

| Scope | `:interact` | `:discover` (preview) | `:unlisted_read` (quiet) |
|-------|-------------|------------------------|--------------------------|
| `global` | `public` | `public:preview` | `public:quiet` |
| `archipelago` | `archipelago` | — | — |
| `nonfederated` | `nonfederated` | `nonfederated:preview` | `nonfederated:quiet` |
| `local` | `local` | `local:preview` | `local:quiet` |
| `members` | `members:private` | — | — |

When a group states no DCV, one is derived from its visibility by `default_content_visibility_for/1`: `global*` → `public`, `local*` → `local`, `members:private` → itself, everything else → `nonfederated`. This matters beyond groups anyone configures here, because `Categories.create_remote/2` scaffolds every **mirrored remote community** through the same path.

### Cascade constraints

Post visibility options are automatically disabled based on group visibility (`disabled_default_content_visibility_options/1`), so a post default can never reach an audience the group itself excludes.

---

## Named Presets (Layer 1)

| Preset ID | Membership | Visibility | Participation | Default post vis |
|-----------|-----------|------------|---------------|-----------------|
| `public_local_community` | `local:members` | `nonfederated:discoverable` | `local:contributors` | `nonfederated` |
| `announcement_channel` | `invite_only` | `nonfederated:discoverable` | `moderators` | `nonfederated` |
| `private_club` | `on_request` | `local:discoverable` | `group_members` | `members:private` |

Federated presets (`open_network` and others) are sketched in config but commented out until groups federation ships.

A group resolves its preset by two different routes, which matters when editing this config: `group_row_chip/1` back-translates from the group's **dimensions**, while `group_icon/2` reads the `[:preset_slug]` **setting** stored at create time. Changing an existing preset's dims breaks the first for groups already created with it; renaming its key breaks the second. Adding a new key breaks neither, with `:group_preset_order` deciding which presets are offered — an entry in `group_presets` but absent from `group_preset_order` still back-translates without being offered for new groups.

## Layer 2 Overrides

A Layer 2 toggle is an override on a preset that enacts one or more Layer 3 dimensions. Both directions live in `Bonfire.Classify.Boundaries`: `layer2_from_dims/1` reads a toggle's state out of the slugs, `dims_from_layer2_overrides/2` writes a flipped toggle back into them. The group boundary editor delegates to the latter rather than keeping its own copy.

| Key | Toggles | Writes to | Locked by |
|-----|---------|-----------|-----------|
| `federate` | Group reachable from other instances | `visibility` **and** `default_content_visibility` scope, at the same role | all presets (until federation ships) |
| `joins_need_approval` | Moderator reviews each join request | `membership` | `announcement_channel`, `private_club` |
| `nonmembers_may_post` | People who have not joined can post | `participation` | `announcement_channel`, `private_club` |


Two of these move along the **scope** axis and pick within the group's own reach rather than a fixed slug, so turning them on in a federated group does not silently produce a local-only result:

- `nonmembers_may_post: true` → `anyone` when the group is federated, `local:contributors` when it is not
- `joins_need_approval: false` → `open` when federated, `local:members` when not

`federate` moves two dimensions at once, because federating a group whose posts still default to a non-federating boundary publishes an empty shell. A `members`-scope slug is left alone by all of these: "members only" has no federated-vs-local counterpart, and taking the same-role slug in another scope would publish a private group.

Toggle values are coerced with `Types.maybe_to_boolean/1`, so form params (`"true"`, `"on"`) work and an unset value is not read as permission granted.
