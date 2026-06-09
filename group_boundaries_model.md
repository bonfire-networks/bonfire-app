# Group Boundary Model — 4 Dimensions

> **Note:** The authoritative source for current dimension slugs, labels, and icons is `extensions/bonfire_boundaries/lib/runtime_config.ex` (`preset_dimensions`) and `extensions/bonfire_classify/lib/runtime_config.ex` (`group_presets`, `layer2_toggles`). The `GET /api/v1-bonfire/boundaries?context=group` endpoint exposes this config at runtime. This document is background reference only.

Groups have four independent boundary dimensions. Each has a small set of meaningful options. Picking a named preset (Layer 1) sets all four at once; Layer 2 toggles and Layer 3 raw dimension values override individual axes.

---

## 1. Membership — who can join

| Slug | Meaning |
|------|---------|
| `open` | Anyone can join freely |
| `local:members` | Anyone on this instance can join |
| `archipelago:members` | Anyone on a trusted/linked instance can join *(not yet implemented)* |
| `on_request` | Anyone can request to join; moderator approves |
| `invite_only` | Only moderators can add members (no join/request button shown) |

## 2. Group visibility — who can see the group and its content (`:see` / `:read` verbs)

| Slug | Scope | Full access | Discoverable only | Unlisted |
|------|-------|-------------|-------------------|---------|
| `nonfederated` / `nonfederated:discoverable` | Public (local only) | `nonfederated` | `nonfederated:discoverable` | — |
| `local` / `local:discoverable` | Local instance | `local` | `local:discoverable` | — |
| `members:private` | Members only | `members:private` | — | — |

*Archipelago-scoped variants are planned but not yet implemented.*

## 3. Participation — who can post/interact (`:create`, `:reply`, `:boost`, `:like` verbs)

| Slug | Meaning | Constraint |
|------|---------|------------|
| `anyone` | Any user | Disabled when visibility is `members:private` |
| `local:contributors` | Local users | Disabled when visibility is `members:private` |
| `group_members` | Members only | Default |
| `moderators` | Moderators only | Members can read and react but not post |

## 4. Default content visibility — how posts in this group are shared by default

| Slug | Scope |
|------|-------|
| `nonfederated` | Visible to anyone on this instance including guests |
| `local` | Visible to logged-in local users |
| `members:private` | Visible to group members only |

*Preview (`:preview`) and quiet (`:quiet`) variants are defined in config for future use.*

### Cascade constraints

Post visibility options are automatically disabled based on group visibility:
- `nonfederated` — disabled when group is `local:*` or `members:private`
- `local` — disabled when group is `members:private`
- `members:private` — always available

---

## Named Presets (Layer 1)

| Preset ID | Membership | Visibility | Participation | Default post vis |
|-----------|-----------|------------|---------------|-----------------|
| `public_local_community` | `local:members` | `nonfederated:discoverable` | `local:contributors` | `nonfederated` |
| `announcement_channel` | `invite_only` | `nonfederated:discoverable` | `moderators` | `nonfederated` |
| `private_club` | `on_request` | `local:discoverable` | `group_members` | `members:private` |

## Layer 2 Overrides

| Key | Toggles | Locked by |
|-----|---------|-----------|
| `discoverable` | Group discoverable in listings/search | — |
| `federate` | Group reachable from other instances | all presets (until federation ships) |
| `approval_required` | Moderator must approve join requests | `announcement_channel`, `private_club` |
| `anyone_posts` | Any eligible user can post (not just members) | `announcement_channel`, `private_club` |
