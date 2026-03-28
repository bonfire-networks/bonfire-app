# Federated Groups - Feature Specifications & Issues

Federated groups enable self-governed spaces where members from different servers coordinate, collaborate, and organize around shared topics without platform lock-in.

---

## Implement group creation and settings

Users with appropriate permissions can create, manage, and delete groups with customizable settings.

- [x] Create new group with name, description, icon, and banner image
- [x] Edit group metadata (name, description, images)
- [x] Lock/archive group
- [x] Delete group and handle cleanup (member removals, content deletion) - soft delete only
- [ ] Set group code of conduct and rules
- [x] Configure membership & privacy settings (Open/Visible/Private presets)

**Related Areas:** Authentication, Permissions, Database Schema

---

## Implement member joining, leaving, and role assignment

Members can join groups, leave at any time, and admins can manage membership, roles, and permissions.

- [x] Users can join open groups with one click (after reading code of conduct)
- [x] Users can request to join moderated-join groups
- [ ] Mods can approve/reject join requests (-> UI structure exists but workflow incomplete)
- [x] Mods can invite specific user to groups (via Bonfire.Invite.Links)
- [x] Members can leave groups at any time
- [ ] Mods can remove members from groups
- [x] Mods can assign member roles (moderator, X, Y, member) - via boundaries integration
- [x] Define permissions per role (post, edit, moderate, curate, invite, delete group)
- [x] Display member list with roles and join dates
- [x] Sidebar navigation: Shows user's groups with nested hierarchy
- [x] Star favourite groups/topics for easy access (uses bookmark functionality) 

**Related Areas:** Permissions, Notifications, Federation

---

## Issue 3: Group Feed & Posts

Members can create posts, discussions, and threaded conversations within a group, separate from their personal feed.

- [x] Post content within a group (create text post, media, etc)
- [x] Posts optionally appear only in group feed (and not profile timeline)
- [x] Reply to posts with nested threaded conversation view
- [x] Edit and delete own posts
- [ ] Mods can remove posts from other members
- [ ] Mods can pin important posts to group top
- [ ] Search posts within group

**Related Areas:** Database, Feed Algorithms, Permissions, Federation

---

## Channels

Groups can have multiple channels (topics/rooms) for different topics, allowing members to organize conversations without everything collapsing into one feed.

- [x] Mods (or members with permission) can create, edit, delete channels within groups
- [x] Channels have names, and descriptions
- [x] Channels have a parent group (or channel), and can be linked to related channels/groups
- [x] Can post within a specific channel
- [x] Channel mentions in posts creates links and posts or submits to channel
- [x] Members can browse and filter by channel
- [ ] Channel membership & privacy settings (see dedicated issue)
- [ ] Optional: Permissions per channel (who can post, view)

**Related Areas:** Database Schema, Permissions, UI/UX

---

## Group Discovery & Exploration

Users can discover and explore public/open groups based on interests, topic, or recommendations.

- [x] Directory of public groups/channels (browsable, searchable, filterable)
- [ ] Filter by category, topic, activity level
- [x] Display group info (size, description, recent activity)
- [x] Search groups by name or keyword
- [ ] Recommended groups curated by instance admins
- [x] Join button or request flow from discovery page (after reading code of conduct)
- [x] Breadcrumb navigation: For tree hierarchy display

**Related Areas:** Search, Recommendations, UI/UX

---

## Group/Channel Visibility, Membership & Participation Settings

Groups can be public, private, or unlisted with fine-grained control over who can see content.

**Visibility:**
- [x] Public groups: discoverable, non-members see group info and posts are public by default
- [x] Private groups: non-members see minimal info and posts are private-to-members by default
- [ ] Unlisted groups: not listed in directories, minimal info visible if you have the group link

**Membership & Participation:**
- [x] Open: anyone can follow, join, and participate
- [x] Semi-open: anyone can follow, and submit posts to mods. Only members can post directly. (partially implemented)
- [x] Closed: anyone can follow, but joining and participation requires requesting-to-join and being approved (or being invited)
- [ ] Invite-only: Following and joining require being invited first

**Federation:**
- [ ] Group archipelago: control which remote servers/actors can see/join (blocklists and allowlists)

**Related Areas:** Permissions, Federation, Database Queries

---

## Implement group-level moderation tools

Admins and moderators can manage content and enforce community standards.

- [x] Standard content flagging/reporting workflow 
- [ ] User can choose to report to group mods and/or instance admins
- [ ] Moderators can approve submitted posts
- [ ] Moderators can hide posts
- [ ] Moderators can remove members
- [ ] Moderators can temporarily suspend members (optional)
- [ ] Moderators can lock discussions
- [ ] Moderators can pin discussions
- [ ] Moderation log visible to mods and instance admins
- [ ] Bulk actions (eg. hide multiple posts)
- [x] Block users or entire remote instances at group level
- [ ] Configure keyword filters

**Related Areas:** Permissions, Notifications, Reporting, Federation

---

## Enable groups to federate with Mastodon and classic platforms (incl ATproto with BridgyFed)

Group posts and activities appear in remote fediverse platforms; remote users can interact at a basic level.

- [x] Posts in group federate as regular ActivityPub activities (with author as the original creator and group actor "Announces" the post)
- [x] Remote users can [request to] follow and unfollow groups (follow/unfollow may act as joining/leaving depending on group settings)
- [x] Remote users can see posts from groups they follow in their feeds
- [x] Remote users can reply to group posts
- [x] Remote users can @-mention groups (which gets posted into the group or including in submitted posts queue for moderation, or only shown to mods depending on permissions)
- [x] Remote users can discover known groups via search

**Related Areas:** ActivityPub, Federation, Serialization


---
## Implement federated group features compatible with "threadiverse" and Mobilizon/Peertube/etc

Bonfire instances and compatible fediverse apps can participate in supported group features.

- [ ] Discover and document how existing implementation federate group membership and activities
- [ ] Test interop with Lemmy, Piefed, Mbin, NodeBB, Discourse, Mobilizon, Peertube, etc
- [ ] Progressive enhancement: features unsupported by remote apps degrade without breaking

**Related Areas:** ActivityPub Spec, Standards, Federation Protocol

---

## Implement full federated group features using ActivityPub extensions

Bonfire instances and compatible fediverse apps can participate fully in group features (members from multiple servers, role sync, etc.).

- [ ] Review, iterate as needed, and implement FEPs (Fediverse Enhancement Proposal) for groups
- [ ] Participate in groups task force of the Social Web Incubator Community Group (SWICG)
- [ ] Define and document data types and properties
- [ ] Remote members join/leaving/suspend
- [ ] Reporting & escalation in groups (see dedicated issue)
- [ ] Cross-instance groups moderation (see dedicated issue)
- [ ] Role and permission changes replicate to remote instances
- [ ] Membership add/removal federates
- [ ] Channels federate with full feature support
- [ ] Test interop with multiple Bonfire instances and any other apps that implement the groups spec
- [ ] Progressive enhancement: features unsupported by remote apps degrade without breaking

**Related Areas:** ActivityPub Spec, Standards, Federation Protocol

---

## Implement reporting and escalation for group violations

Members can report content or behavior to group and/or instance moderators.

- [x] Members can report posts, comments, or other members
- [ ] Report includes reason and optional description/context (included in federation)
- [ ] Reports go to group moderators by default (can also go to reporter's instance admins)
- [x] Group has separate reports queue from instance
- [ ] Group mods can escalate to instance admins (up to 3 instances: group's home instance, mod's instance, and author's instance)
- [ ] Report status tracking (new, being-reviewed, being-discussed, waiting-for-response, resolved, dismissed, and the like)
- [ ] Notifications/reports go to relevant moderators (based on reported reason + keyword filtering?)
- [ ] Reporter privacy options (anonymous or identified)
- [ ] Mod privacy options (anonymous or identified)
- [ ] Report history and patterns visible to mods/admins

**Related Areas:** Moderation, Notifications, Permissions

---

## Federate moderation decisions across instances

When a moderator removes a post or member on one server, that action is communicated and inherited by other federated servers to avoid duplicated moderation work.

- [ ] Post removal federates to group members
- [ ] Member removal federates
- [ ] Groups can have remote moderators
- [ ] Moderation log accessible to remote mods
- [ ] Instance/user blocks by group mods federate appropriately

**Related Areas:** Federation, Moderation, Conflict Resolution

---

## Implement notification system for group activities

Members receive timely notifications about group events, replies, and administrative changes.

- [ ] Notify on new post in group (opt-in per group or channel)
- [ ] Notify on reply to a post
- [ ] Notify on mod actions (removal, suspension, role changes)
- [ ] Optional Notify on membership changes (new member joined, member left)
- [ ] Email digest options (eg. daily, weekly)

**Related Areas:** Notifications System, User Preferences

---

## Enable groups to move between servers with content and membership intact

Groups and their members can migrate to a different server without losing history or relationships (full portability).

- [ ] Mods can export group data (posts, members, metadata, settings)
- [ ] Import group data from another server
- [ ] Redirect old group to new group on different server
- [ ] Follows/memberships get moved automatically
- [ ] If a member moves instance, their membership gets preserved automatically
- [ ] Document migration process for mods
- [ ] Optional: Automated migration workflow

**Related Areas:** Federation, Database, Import/Export

---

## Implement admin and moderation dashboard

Admins and moderators manage group settings, members, content, and moderation from a dedicated interface.

- [x] Mod dashboard overview (members, pending posts, reports, other events)
- [x] Member management (invite, remove, role assignment) - partial
- [x] Reports queue with details and status (approve/remove posts, manage reports)
- [x] Settings panel (group metadata, privacy, membership, code of conduct)
- [ ] Moderation log with search and filters, and audit trail (who changed what, when)
- [ ] Analytics (member growth, activity, discussions)
- [ ] Bulk actions (ban users, remove content, export data)
- [ ] Role templates and permission presets

**Related Areas:** UI/UX, Permissions, Admin Tools

---

## Document federated groups specification and implementation guide

Publish comprehensive documentation for developers and community admins on how groups work, federation, and standards alignment.

- [ ] User guide (how to join, participate in groups)
- [ ] Mod guide (create, configuration, moderation)
- [ ] Developer documentation (API, ActivityPub extensions, data models and extension points)
- [ ] Interoperability guide (tests with other fediverse apps), FEPs documentation and examples, with example JSON payloads and test fixtures
- [ ] Migration guide (for existing forum/group communities)
- [ ] Code of conduct, moderation, and accessibility guidelines for group builders
- [ ] Troubleshooting and FAQ

**Related Areas:** Documentation, Standards, Developer Experience

---

## Implement & test robust authorization and security for groups

Ensure permissions, encryption, and access control prevent unauthorized actions and data leaks.

- [x] Permission inheritance (group -> channel -> discussion level)
- [ ] Optional: functionality to retroactively change visibility/permissions of group posts when changing group settings
- [x] Secure remote member/mod authentication (federation) - via ActivityPub signatures
- [ ] Optional: End-to-end encryption for private group communications
- [ ] Rate limiting on group actions
- [ ] Audit logging of security & mod events

**Related Areas:** Security, Authentication, Permissions

---

## APIs for groups

- [x] GraphQL API: Full CRUD operations
- [ ] Mastodon API: add extensions for group/channel properties / endpoints (compatible with Newsmast)

---

# SWICG Groups Taskforce Alignment

This section maps features from the [SWICG Groups Taskforce](https://swicg.github.io/groups/) specification to Bonfire's implementation.

## User Stories - Full Match

These SWICG user stories match features in Bonfire:

- [x] **[Join a group][1]** - "As an ActivityPub user, I want to join a group, so I can be part of it."

- [x] **[Leave a group][2]** - "As an ActivityPub user, I want to leave a group I'm a member of."

- [x] **[Create a group][3]** - "As an ActivityPub user, I want to create a group."

- [x] **[Invite to a group][4]** - "As an ActivityPub user, I want to invite someone to a group."

- [x] **[Get list of members][6]** - "As an ActivityPub user, I want to get a list of members of a group."

- [x] **[Get list of admins][7]** - "As an ActivityPub user, I want to get the list of admins for a group."

- [x] **[Post content publicly][12]** - "As a group member, I want to post content visible to the public."

- [x] **[Post content privately][13]** - "As a group member, I want to post content visible to group members only."

- [x] **[Get a stream of content][14]** - "As a group member, I want to see a feed of content posted to the group."

- [x] **[Close a group][16]** - "As a group owner, I want to close down a group."

- [x] **[Get group info][21]** - "As an ActivityPub user, I want to get information about the group."

- [x] **[Change group info][22]** - "As a group owner, I want to change information about the group."

- [x] **[Review & approve group posts][23]** - "As a group admin, I want to review posts before they are distributed."

- [x] **[Expel from a group][5]** - "As a group administrator, I want to expel a member from a group."

- [x] **[Accept a Join request][10]** - "As a group admin, I would like to accept a Join request."

- [x] **[Reject a Join request][11]** - "As a group admin, I want to reject a Join request."


## User Stories - Partial Match

These SWICG user stories are partially implemented or need work:

- [ ] **[Invite to admin][8]** - "As a group owner, I would like to invite a group member to become an admin."
  - Bonfire: Role assignment works via boundaries/ACL, but no dedicated "invite to admin" flow

- [ ] **[Expel an admin][9]** - "As a group owner, I want to expel an admin."
  - Bonfire: Can change roles via boundaries, but no explicit admin expulsion flow

- [ ] **[Add to a group collection][18]** - "As a group member, I want to add content to a group collection."

- [ ] **[Remove from a group collection][19]** - "As a group member, I want to remove content from a group collection."

- [ ] **[Transfer group ownership][20]** - "As a group owner, I want to transfer ownership to another actor."
  - Bonfire: Not explicitly implemented

## Group Representation Properties

Mapping SWICG properties to Bonfire implementation:

| SWICG Property | Bonfire Equivalent | Status |
|----------------|-------------------|--------|
| `id` | `category.id` (ULID, canonical URL via character) | ✅ Implemented |
| `type: Group` | `category.type = :group` (enum) | ✅ Implemented |
| `name` | `profile.name` | ✅ Implemented |
| `summary` | `profile.summary` | ✅ Implemented |
| `image` | `profile.image_id` (banner) | ✅ Implemented |
| `icon` | `profile.icon_id` | ✅ Implemented |
| `members` | (as circle) | ✅ Implemented  |
| `admins` | Queried via `:mediate` verb in boundaries | ✅ Implemented (different mechanism) |
| `attributedTo` (owner) | | ✅ Implemented |
| `collections` | Not implemented | ❌ Missing |
| `inbox` | Submitted tab / notifications inbox | ⚠️ Partial (not as AP collection) |
| `pendingMembers` | Join requests in membership settings | ⚠️ Partial (not as AP collection) |
| `inbox` | Character has inbox for federation | ✅ Implemented |
| `outbox` | Character has outbox for federation | ✅ Implemented |

## Protocol Activities

Mapping SWICG protocol activities to Bonfire:

| Activity | SWICG Use | Bonfire Status |
|----------|-----------|----------------|
| `Create` (Group) | Create a group | ✅ `ap_publish_activity/3` |
| `Update` (Group) | Change group info | ✅ Implemented |
| `Delete` (Group) | Close a group | ✅ Soft delete, federation TBD |
| `Join` | Request to join | ⚠️ Uses `Follow` instead |
| `Leave` | Leave a group | ⚠️ Uses `Undo Follow` instead |
| `Accept` (Join) | Accept join request | ❌ Not implemented |
| `Reject` (Join) | Reject join request | ❌ Not implemented |
| `Invite` | Invite to group | ⚠️ Via invite links, not AP `Invite` |
| `Remove` (member) | Expel member | ❌ Not implemented |
| `Create` (post) | Post to group | ✅ Implemented |
| `Announce` | Redistribute to members | ✅ Group actor announces posts |
| `Accept` (post) | Approve pending post | ❌ Not implemented |
| `Reject` (post) | Reject pending post | ❌ Not implemented |
| `Add` (to collection) | Add to group collection | ❌ Not implemented |
| `Remove` (from collection) | Remove from collection | ❌ Not implemented |

## Bonfire Features NOT in SWICG Spec

Features implemented in Bonfire that are not (yet) defined in the SWICG Groups Taskforce:

- **Channels/Subcategories** - Hierarchical tree structure + related to links
- **Category types** - Distinguish Groups, Channels/Topics, Labels, etc
- **Boundary presets** - Open/Visible/Private with fine-grained permission inheritance
- **Channel mentions** - mentioning channels submits a post to inbox for possible Announce in outbox
- **Group-scoped flagging** - Reports queue separate from instance
- **Remote instance blocking** - Block at group level

## SWICG Spec - TBD or Undefined

Areas marked as TBD in the SWICG spec that Bonfire may need to track:

- [ ] **Collections protocol** - "TBD" - How to Add/Remove from group collections
- [ ] **Admins protocol** - "TBD" - Detailed admin management activities
- [ ] **Alternative designs** - "TBD" - Different approaches being considered
- [ ] **Open issues** - "TBD" - Including:
  - Should Group be an actor with inbox/outbox? (we think yes)
  - Who can invite others? Protocol-defined or implementation-dependent?
  - Who can expel members? Owner, admins, members?
  - Does Delete need boundaries?
  - Do permissions of Note extend to all members or just group actor?
  - Are all activities shared with all members? (Like, Question, etc.)

---


# FEP-1b12: Group Federation Alignment

This section maps features from [FEP-1b12: Group federation][fep-1b12] to Bonfire's implementation. FEP-1b12 describes how to represent and federate Groups in ActivityPub, with a focus on interoperability with Lemmy, Friendica, Hubzilla, Lotide, and PeerTube.

## Core Concepts - Match Status

### Group Actor

| FEP-1b12 Requirement | Bonfire Status | Notes |
|---------------------|----------------|-------|
| Group represented as `type: Group` actor | ✅ Implemented | Via `character` with group category type |
| Group has `inbox` | ✅ Implemented | Character-based inbox |
| Group has `outbox` | ✅ Implemented | Character-based outbox |
| Group has `followers` collection | ✅ Implemented | Members as followers |
| Moderators in `attributedTo` collection | ⚠️ Partial | Mods tracked via boundaries, not `attributedTo` collection |

### Following a Group (Membership)

| FEP-1b12 Requirement | Bonfire Status | Notes |
|---------------------|----------------|-------|
| User sends `Follow` to join | ✅ Implemented | Follow acts as join request |
| Group sends `Accept(Follow)` for approval | ✅ Implemented | For open groups, automatic accept |
| Membership = being in `followers` collection | ✅ Implemented | Members tracked as followers |
| `Undo(Follow)` to leave group | ✅ Implemented | Unfollow removes membership |

### Audience Property

| FEP-1b12 Requirement | Bonfire Status | Notes |
|---------------------|----------------|-------|
| Posts use `audience` property to indicate group | ⚠️ Partial | Group ID included, but may use `context` instead of `audience` |
| `audience` contains Group actor ID | ⚠️ Partial | Need to verify exact property used |

### Threads and Comments

| FEP-1b12 Requirement | Bonfire Status | Notes |
|---------------------|----------------|-------|
| Threads as `Page` type with `name` property | ❌ Different | Bonfire uses standard posts, not `Page` type |
| Comments as `Note` with `inReplyTo` | ✅ Implemented | Standard threaded replies |
| Nested comments via `inReplyTo` chain | ✅ Implemented | Full threading support |

### Announce Activity

| FEP-1b12 Requirement | Bonfire Status | Notes |
|---------------------|----------------|-------|
| Group wraps posts in `Announce` | ✅ Implemented | Group actor announces member posts |
| `Announce` distributed to followers | ✅ Implemented | Federation via outbox |
| Original post preserved in `object` | ✅ Implemented | Standard ActivityPub pattern |

### Moderation

| FEP-1b12 Requirement | Bonfire Status | Notes |
|---------------------|----------------|-------|
| Moderators listed in `attributedTo` | ❌ Different | Uses boundaries/ACL system |
| `Add` activity to add moderator | ❌ Not implemented | Role changes via boundaries UI only |
| `Remove` activity to remove moderator | ❌ Not implemented | Role changes via boundaries UI only |
| Moderation activities validated against `attributedTo` | ⚠️ Partial | Validated against boundaries instead |

## Protocol Activities Mapping

| FEP-1b12 Activity | Purpose | Bonfire Status |
|-------------------|---------|----------------|
| `Follow` (to Group) | Request membership | ✅ Implemented |
| `Accept(Follow)` | Approve membership | ✅ Implemented |
| `Reject(Follow)` | Deny membership | ❌ Not implemented |
| `Undo(Follow)` | Leave group | ✅ Implemented |
| `Create(Page)` | Create thread | ⚠️ May use Note/Article instead |
| `Create(Note)` | Create comment | ✅ Implemented |
| `Announce` | Distribute to members | ✅ Implemented |
| `Add` (moderator) | Add moderator | ❌ Not implemented |
| `Remove` (moderator) | Remove moderator | ❌ Not implemented |
| `Delete` | Remove content | ✅ Soft delete implemented |
| `Update` | Edit content/group | ✅ Implemented |

## Interoperability Status

FEP-1b12 notes implementations in several platforms. Bonfire's compatibility:

| Platform | Compatibility Notes |
|----------|-------------------|
| **Lemmy** | ⚠️ Partial - Different thread model (Page vs Note), needs testing |
| **Friendica** | ⚠️ Partial - Should work for basic Follow/Announce, needs testing |
| **Hubzilla** | ⚠️ Partial - Complex permission model, needs testing |
| **Lotide** | ⚠️ Unknown - Needs testing |
| **PeerTube** | ⚠️ Partial - Video focus, channel model differs |

## Bonfire Features NOT in FEP-1b12

Features implemented in Bonfire not covered by FEP-1b12:

- **Channels/Subcategories** - Hierarchical tree structure within groups
- **Boundary-based permissions** - Fine-grained ACL system for roles
- **Join request workflow** - Pending members queue for non-open groups
- **Post submission queue** - Submitted posts for mod approval before Announce
- **Group-scoped flagging** - Reports queue at group level
- **Instance blocking** - Block remote instances at group level
- **Invites** - Invite people to join a group
- **Category types** - Distinguish Groups from Topics/Channels/Labels

## FEP-1b12 Requirements NOT Met

Key gaps to address for full FEP-1b12 compliance:

- [ ] **`audience` property** - Verify and ensure proper `audience` property on group posts
- [ ] **Page type for threads** - Consider supporting `Page` type for Lemmy compatibility
- [ ] **`attributedTo` for moderators** - Expose moderators in `attributedTo` collection
- [ ] **Add/Remove activities** - Implement Add/Remove for moderator changes
- [ ] **Reject(Follow)** - Implement rejection of join requests via federation
- [ ] **Interop testing** - Systematic testing with Lemmy, Friendica, etc.


---

# FEP-400e: Publicly-appendable Collections Alignment

This section maps features from [FEP-400e: Publicly-appendable ActivityPub collections][fep-400e] to Bonfire's implementation. FEP-400e describes how to handle collections where others can contribute content (like walls, forums, photo albums in groups) while the owner retains authority.

## Core Concepts - Match Status

### Collection Ownership and Authority

| FEP-400e Requirement | Bonfire Status | Notes |
|---------------------|----------------|-------|
| Collection has valid globally-unique `id` | ✅ Implemented | Category/group has canonical URL |
| Collection owner retains complete authority | ✅ Implemented | Via boundaries/ACL system |
| Collection exposed in actor representation | ⚠️ Partial | Group outbox exposed, but not as named collection field |

### Using `target` in Objects

| FEP-400e Requirement | Bonfire Status | Notes |
|---------------------|----------------|-------|
| Objects include `target` field with collection reference | ⚠️ Partial | May use `context` instead of `target` |
| `target` contains `type`, `id`, `attributedTo` | ⚠️ Partial | Need to verify exact structure |
| Object understood in context of collection | ✅ Implemented | Posts associated with group/channel |

### Add/Remove Activities

| FEP-400e Requirement | Bonfire Status | Notes |
|---------------------|----------------|-------|
| Server sends `Add` activity when object added to collection | ❌ Not implemented | Uses `Announce` instead |
| Server sends `Delete` activity for removal | ✅ Implemented | Soft delete federates |
| Server sends `Move` activity between collections | ❌ Not implemented | No cross-collection move |

## Protocol Activities Mapping

| FEP-400e Activity | Purpose | Bonfire Status |
|-------------------|---------|----------------|
| `Create` with `target` | Create object in collection | ⚠️ Different - uses `context` or group mention |
| `Add` | Confirm object added to collection | ❌ Not implemented (uses Announce) |
| `Delete` | Remove object from collection | ✅ Implemented |
| `Move` | Move between collections | ❌ Not implemented |
| `Reject{Create}` | Reject submission | ❌ Not implemented |

## Bonfire Features Related to FEP-400e

- **Post submission queue** - Aligns with FEP-400e's moderation concept
- **Channel/group posting** - Posts belong to collections, but uses different mechanism
- **Group authority** - Owner/mod authority over content aligns with FEP-400e intent

## FEP-400e Requirements NOT Met

- [ ] **`target` field usage** - Implement proper `target` field instead of/alongside `context`
- [ ] **`Add` activity** - Send `Add` when confirming post to group (currently uses `Announce`)
- [ ] **`Move` activity** - Support moving posts between channels/groups
- [ ] **`Reject{Create}`** - Federate rejection of submitted posts
- [ ] **Collection endpoints** - Expose named collection fields in group actor

---

# FEP-db0e: Non-public Group Authentication Alignment

This section maps features from [FEP-db0e: Authentication mechanism for non-public groups][fep-db0e] to Bonfire's implementation. FEP-db0e defines "actor tokens" for authenticating access to private group content hosted on other servers.

## Core Concepts - Match Status

### Actor Tokens

| FEP-db0e Requirement | Bonfire Status | Notes |
|---------------------|----------------|-------|
| `sm:actorToken` endpoint in actor | ❌ Not implemented | No token endpoint |
| Token with `issuer`, `actor`, timestamps | ❌ Not implemented | No token generation |
| RSA-SHA256 signed tokens | ❌ Not implemented | No token signing |
| Time-limited validity (max 2 hours) | ❌ Not implemented | N/A |

### Fetching Private Content

| FEP-db0e Requirement | Bonfire Status | Notes |
|---------------------|----------------|-------|
| HTTP signature for fetching from group server | ✅ Implemented | Standard AP signatures |
| Actor token for fetching from other servers | ❌ Not implemented | No token-based auth |
| `Authorization: ActivityPubActorToken` header | ❌ Not implemented | N/A |

### Token Verification

| FEP-db0e Requirement | Bonfire Status | Notes |
|---------------------|----------------|-------|
| Verify HTTP signature matches token `actor` | ❌ Not implemented | N/A |
| Check validity timestamps | ❌ Not implemented | N/A |
| Verify object belongs to collection owned by `issuer` | ❌ Not implemented | N/A |

## Bonfire's Current Approach

Bonfire uses a different approach for private group content:

- **Boundaries system** - Fine-grained ACL controls visibility
- **HTTP signatures** - Standard ActivityPub authentication
- **Server-side enforcement** - Visibility checked on fetch

## FEP-db0e Implementation Status

This FEP is largely **not implemented** in Bonfire. The boundaries system provides local access control, but the federated token mechanism for cross-server private group content verification is not present.

### Gaps to Address

- [ ] **Actor token endpoint** - Add `sm:actorToken` endpoint to group actors
- [ ] **Token generation** - Implement signed token creation for members
- [ ] **Token verification** - Accept and verify tokens on content fetch
- [ ] **Cross-server private groups** - Enable private group content to be fetched securely from member's servers

### Considerations

- FEP-db0e is primarily implemented by Smithereen
- May be needed for full private group interop with Smithereen
- Bonfire's boundaries system may need adapter layer for this mechanism


---

# Specification Comparison

This section compares the SWICG Groups Taskforce specification with the FEPs to understand their relationships, overlaps, and differences.

## Scope and Focus

| Specification | Primary Focus | Status |
|---------------|--------------|--------|
| **SWICG Groups Taskforce** | Comprehensive group protocol with user stories | Draft/In Progress |
| **FEP-1b12** | Practical group federation (Lemmy-compatible) | Final |
| **FEP-400e** | Publicly-appendable collections (building block) | Final |
| **FEP-db0e** | Private group authentication via actor tokens | Final |
| **FEP-044f** | Consent-based interactions (quotes, replies) | Draft |
| **GoToSocial interactionPolicy** | Post-level interaction controls with approval workflows | Implemented |
| **Pixelfed capabilities** | Simple binary interaction controls | Implemented |

## Group Actor Representation

| Aspect | SWICG | FEP-1b12 | FEP-400e | FEP-db0e |
|--------|-------|----------|----------|----------|
| Type | `Group` | `Group` | N/A (collection-focused) | N/A (auth-focused) |
| Has inbox/outbox | Yes (recommended) | Yes | N/A | Yes (for tokens) |
| Moderators | `admins` collection | `attributedTo` collection | `attributedTo` (owner) | N/A |
| Members | `members` collection | `followers` collection | N/A | N/A |

**Key difference**: SWICG uses explicit `members`/`admins` collections, while FEP-1b12 repurposes `followers` for members and `attributedTo` for moderators (Lemmy compatibility).

## Membership Protocol

| Action | SWICG | FEP-1b12 |
|--------|-------|----------|
| Request to join | `Join` activity | `Follow` activity |
| Leave group | `Leave` activity | `Undo(Follow)` activity |
| Approve join | `Accept(Join)` | `Accept(Follow)` |
| Reject join | `Reject(Join)` | `Reject(Follow)` |
| Remove member | `Remove` activity | Not specified |
| Invite member | `Invite` activity | Not specified |

**Key difference**: SWICG defines dedicated `Join`/`Leave` activities, while FEP-1b12 reuses the existing `Follow` mechanism. FEP-1b12's approach has wider existing implementation support (Lemmy, Friendica, etc.).

## Post Distribution Model

| Aspect | SWICG | FEP-1b12 | FEP-400e |
|--------|-------|----------|----------|
| Post targeting | Not fully specified | `audience` property | `target` property |
| Distribution | `Announce` (implied) | `Announce` by group actor | `Add` by collection owner |
| Moderation queue | `Accept`/`Reject` post | Not specified | `Reject{Create}` |
| Content removal | Not specified | `Delete` | `Delete` |

**Key insight**: FEP-1b12 and FEP-400e offer **complementary** approaches:
- FEP-1b12's `Announce` model: Group actor redistributes posts to followers
- FEP-400e's `Add` model: Collection owner confirms content belongs to collection

These could be used together: `Add` to confirm membership in collection, `Announce` to distribute.

## Moderation and Roles

| Aspect | SWICG | FEP-1b12 | FEP-400e |
|--------|-------|----------|----------|
| Moderator discovery | `admins` collection | `attributedTo` collection | `attributedTo` (owner only) |
| Add moderator | TBD | `Add` activity | N/A |
| Remove moderator | TBD | `Remove` activity | N/A |
| Authority model | Owner + admins | Moderators in `attributedTo` | Single owner |

**Key difference**: FEP-400e assumes single owner authority, while SWICG and FEP-1b12 support multiple moderators.

## Private/Restricted Groups

| Aspect | SWICG | FEP-1b12 | FEP-db0e |
|--------|-------|----------|----------|
| Private content | Mentioned (user story) | Not addressed | Primary focus |
| Auth mechanism | Not specified | N/A | Actor tokens |
| Cross-server fetch | Not specified | N/A | Token in Authorization header |

**Key insight**: FEP-db0e fills a gap left by SWICG and FEP-1b12 - how do federated servers authenticate access to private group content when the content is hosted on a member's server?

## Compatibility Matrix

| | SWICG | FEP-1b12 | FEP-400e | FEP-db0e | FEP-044f | GoToSocial | Pixelfed |
|---|-------|----------|----------|----------|----------|------------|----------|
| **SWICG** | — | ⚠️ Different membership model | ✅ Complementary | ✅ Complementary | ✅ Complementary | ✅ Complementary | ✅ Complementary |
| **FEP-1b12** | ⚠️ Different membership model | — | ⚠️ Different distribution model | ✅ Complementary | ✅ Complementary | ✅ Complementary | ✅ Complementary |
| **FEP-400e** | ✅ Complementary | ⚠️ Different distribution model | — | ✅ Complementary | ✅ Complementary | ✅ Complementary | ✅ Complementary |
| **FEP-db0e** | ✅ Complementary | ✅ Complementary | ✅ Complementary | — | ✅ Complementary | ✅ Complementary | ✅ Complementary |
| **FEP-044f** | ✅ Complementary | ✅ Complementary | ✅ Complementary | ✅ Complementary | — | ✅ Same vocabulary | ⚠️ Simpler model |
| **GoToSocial** | ✅ Complementary | ✅ Complementary | ✅ Complementary | ✅ Complementary | ✅ Same vocabulary | — | ⚠️ Richer model |
| **Pixelfed** | ✅ Complementary | ✅ Complementary | ✅ Complementary | ✅ Complementary | ⚠️ Simpler model | ⚠️ Simpler model | — |

## Conflicts and Tensions

### 1. Membership: `Join` vs `Follow`

- **FEP-1b12** uses `Follow`/`Undo(Follow)` (established practice)
- **SWICG** defines `Join`/`Leave` as dedicated activities

**Resolution**: FEP-1b12's approach has wider adoption. SWICG may need to accommodate both or defer to existing practice.

### 2. Post Distribution: `Announce` vs `Add`

- **FEP-1b12** uses `Announce` (group actor boosts the post)
- **FEP-400e** uses `Add` (post added to collection)

**Resolution**: Not mutually exclusive. Could use `Add` for collection semantics and `Announce` for distribution. However, implementations must agree on which to expect.

### 3. Moderator Discovery: `admins` vs `attributedTo`

- **SWICG** proposes `admins` collection
- **FEP-1b12** uses `attributedTo` collection

**Resolution**: `attributedTo` has existing implementation (Lemmy). SWICG could adopt this or define `admins` as an alias.

---

# Implementation Comparison

This table compares Bonfire against specifications and other fediverse implementations. Note that some platforms (WordPress, Discourse, NodeBB) have emerging/experimental AP support.

## Threadiverse & Social Platforms

| Feature | Bonfire | Lemmy | mbin | piefed | Friendica | Hubzilla |
|---------|---------|-------|------|--------|-----------|----------|
| **Group term** | Group/Channel | Community | Magazine | Community | Forum | Forum/Channel |
| **Actor type** | `Group` | `Group` | `Group` | `Group` | `Group` | `Group` |
| **Has inbox/outbox** | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Group creation** | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Membership model** | Follow/Accept | Follow/Accept | Follow/Accept | Follow/Accept | Follow/Accept | Follow/Accept |
| **Moderators in `attributedTo`** | ❌ (uses boundaries) | ✅ | ✅ | ✅ | Partial | ✅ |
| **Thread type** | Note/Article | Page | Page | Page | Note | Note |
| **Post distribution** | Announce | Announce | Announce | Announce | Announce | Announce |
| **`audience` property** | Partial | ✅ | ✅ | ✅ | Partial | Partial |
| **Subcategories/channels** | ✅ (tree hierarchy) | ❌ | ❌ | ❌ | ❌ | ✅ (nested forums) |
| **Private groups** | ✅ (boundaries) | Partial | Partial | Partial | ✅ | ✅ (permissions) |
| **Actor tokens (FEP-db0e)** | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| **Join request approval** | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **`Reject(Follow)`** | ❌ | ✅ | ✅ | ? | ? | ? |
| **Federated mod actions** | Partial | ✅ | ✅ | Partial | Partial | Partial |
| **Group-level instance blocks** | ✅ | ✅ | ✅ | ? | Partial | ✅ |
| **Rules/CoC field** | Partial | ✅ | ✅ | ? | ❌ | ❌ |
| **FEP-1b12 compliance** | Partial | ✅ (origin) | ✅ | ✅ | ✅ (explicit) | Partial |
| **Interaction controls** | Planned (`interactionPolicy`) | ❌ | ❌ | ❌ | ❌ | ❌ |

## Interaction Control Implementations

| Feature | Bonfire | GoToSocial | Pixelfed | Mastodon |
|---------|---------|------------|----------|----------|
| **Vocabulary** | `interactionPolicy` (planned) | `interactionPolicy` | `capabilities` | N/A |
| **Scope** | Group + post level | Post level | Post level | N/A |
| **Approval workflow** | `automaticApproval`/`manualApproval` | `automaticApproval`/`manualApproval` | Binary (null/Public) | N/A |
| **Audience targeting** | `as:Public`, `followers`, actors, collections | `as:Public`, `followers`, actors | `as:Public` only | N/A |
| **FEP-044f alignment** | Planned | Partial | ❌ | N/A |
| **Group-level controls** | ✅ (planned) | ❌ (post only) | ❌ (post only) | N/A |

## Event & Media Platforms

| Feature | Mobilizon | PeerTube | Funkwhale |
|---------|-----------|----------|-----------|
| **Group term** | Group | Channel | Channel |
| **Actor type** | `Group` | `Group` (for channels) | `Group` |
| **Primary content** | Events | Videos | Audio |
| **Has inbox/outbox** | ✅ | ✅ | ✅ |
| **Membership model** | Follow + RSVP | Follow only | Follow only |
| **Is community group?** | ✅ (organizes events) | ❌ (user-owned channel) | ❌ (user-owned) |
| **Threaded discussions** | Event comments | Video comments | Track comments |
| **Federation with threadiverse** | Partial | Partial (videos appear) | Limited |

## Emerging/Experimental

| Feature | Smithereen | WordPress (AP) | Discourse | NodeBB |
|---------|------------|----------------|-----------|--------|
| **Group term** | Group | Blog (as Group) | Category | Category |
| **Actor type** | `Group` | `Group` | ? | `Group` |
| **Has inbox/outbox** | ✅ | ✅ | ? | ✅ |
| **Membership model** | Follow/Accept | Follow | ? | Follow/Accept |
| **Actor tokens (FEP-db0e)** | ✅ | ❌ | ❌ | ❌ |
| **Private groups** | ✅ (tokens) | N/A | Local only | Partial (chat rooms) |
| **Thread type** | Note | Article | ? | Note |
| **Federated groups** | ✅ | Partial (blog-as-group) | Planned | ✅ (FEP-1b12) |
| **Maturity** | Active | Stable plugin | In development | Active |
| **`audience` property** | Partial (uses to/cc) | ? | ? | ✅ |
| **Resolvable `context` ([FEP-7888][fep-7888])** | ❌ (uses `target`) | ❌ | ? | ✅ |
| **`replies` collection ([FEP-7458][fep-7458])** | ✅ | ❌ | ? | Partial |
| **FEP-400e (`target`/`Add`)** | ✅ | ❌ | ? | ❌ |
| **Collection query endpoint** | ✅ (`sm:collectionSimpleQuery`) | ❌ | ? | ❌ |
| **Group invitations** | ✅ (`Invite{Group}`) | ❌ | ? | ? |

## Specification Alignment Summary

| Feature | SWICG | FEP-1b12 | FEP-400e | FEP-db0e | FEP-044f | GoToSocial | Pixelfed |
|---------|-------|----------|----------|----------|----------|------------|----------|
| **Membership activity** | `Join`/`Leave` | `Follow`/`Undo(Follow)` | N/A | N/A | N/A | N/A | N/A |
| **Moderator location** | `admins` collection | `attributedTo` | `attributedTo` (owner) | N/A | N/A | N/A | N/A |
| **Post targeting** | TBD | `audience` | `target` | N/A | N/A | N/A | N/A |
| **Distribution method** | `Announce` implied | `Announce` | `Add` | N/A | N/A | N/A | N/A |
| **Private auth** | Not specified | Not specified | Not specified | Actor tokens | N/A | N/A | N/A |
| **Mod changes** | TBD | `Add`/`Remove` | N/A | N/A | N/A | N/A | N/A |
| **Content rejection** | `Reject` | Not specified | `Reject{Create}` | N/A | `Accept`/`Reject` | N/A | N/A |
| **Interaction controls** | Not specified | Not specified | Not specified | N/A | `interactionPolicy` | `interactionPolicy` | `capabilities` |
| **Approval workflow** | Not specified | Not specified | Not specified | N/A | `automaticApproval`/`manualApproval` | `automaticApproval`/`manualApproval` | Binary (null/Public) |
| **Consent requests** | Not specified | Not specified | Not specified | N/A | `QuoteRequest`/`ReplyRequest` | N/A | N/A |

---

## Recommendations for Bonfire

Based on this analysis, recommended approach for Bonfire:

### Adopt from FEP-1b12 (pragmatic interop)
- [x] `Follow`/`Undo(Follow)` for membership ✅ Already implemented
- [ ] `audience` property on group posts
- [ ] `attributedTo` for moderators (expose alongside boundaries)
- [x] `Announce` for post distribution ✅ Already implemented

### Adopt from FEP-400e (collection semantics)
- [ ] `target` property on posts (alongside `context`)
- [ ] Consider `Add` activity for explicit collection membership
- [ ] `Reject{Create}` for moderation queue rejections

### Adopt from FEP-db0e (private groups)
- [ ] Actor tokens for private group interop (lower priority unless Smithereen interop needed)

### Adopt from FEP-044f / GoToSocial (interaction controls)
- [ ] `interactionPolicy` property on Group actors to express permissions
- [ ] `automaticApproval`/`manualApproval` arrays for nuanced permission targeting
- [ ] Map Bonfire boundaries to `interactionPolicy` for federation discovery
- [ ] Support `canJoin`, `canPost`, `canModerate`, `canGrant` etc. action types
- [ ] Reference parent group collections in channel `interactionPolicy` for permission inheritance

### Adopt from Pixelfed (simple compatibility)
- [ ] Understand incoming `capabilities` property on posts
- [ ] Fall back gracefully when `interactionPolicy` not present

### Keep from SWICG (future-proofing)
- [ ] Track `Join`/`Leave` activity developments
- [ ] Support `admins` collection alongside `attributedTo`
- [ ] Implement `Invite` activity when standardized
- [ ] Track separate `members` collection (distinct from `followers`) for subscription vs membership

### Bonfire-specific (beyond specs)
- Boundaries/ACL system provides richer permissions than any spec
- Channels/subcategories extend group concept
- Group-scoped flagging for moderation
- Cross-instance moderation flows using `interactionPolicy` + `Accept`/`Reject`

---

## Proposed: Group-Level Interaction Policy Vocabulary

Inspired by [GoToSocial's `interactionPolicy`](https://docs.gotosocial.org/en/latest/federation/interaction_controls/) and [FEP-044f] for post-level controls, we propose a similar vocabulary for **group-level interaction controls** that could express Bonfire's boundaries/ACL system in a federated way.

### Rationale

Current specs define *what* groups can do (FEP-1b12, FEP-400e) but not *who* can do *what* within a group. Different platforms implement this differently:
- Lemmy: hardcoded role system (admin, mod, member)
- Mastodon: no group support
- Pixelfed: `capabilities` property (simple on/off controls)
- GoToSocial: post-level `interactionPolicy` (could extend to groups)
- Bonfire: flexible boundaries/ACL system

A standardized vocabulary would enable:
1. **Federated permission discovery**: Remote servers can query what actions are allowed
2. **Interoperability**: Different implementations can map their permission systems
3. **Transparency**: Users know what they can do before attempting actions

### Prior Art: Existing Interaction Control Vocabularies

#### Pixelfed's `capabilities`

Pixelfed implements a simple `capabilities` property for comment controls:

```json
{
  "@context": [
    "https://www.w3.org/ns/activitystreams",
    {
      "pixelfed": "http://pixelfed.org/ns#",
      "capabilities": {"@id": "pixelfed:capabilities", "@container": "@set"},
      "announce": {"@id": "pixelfed:canAnnounce", "@type": "@id"},
      "like": {"@id": "pixelfed:canLike", "@type": "@id"},
      "reply": {"@id": "pixelfed:canReply", "@type": "@id"}
    }
  ],
  "type": "Note",
  "id": "https://pixelfed.example/p/user/123",
  "capabilities": {
    "announce": "https://www.w3.org/ns/activitystreams#Public",
    "like": "https://www.w3.org/ns/activitystreams#Public",
    "reply": null
  }
}
```

**Characteristics:**
- Binary control: either `null` (disabled) or `as:Public` (enabled for everyone)
- Simple to implement and understand
- Limited expressiveness: no audience targeting, no approval workflows
- Also includes `commentsEnabled` boolean

#### GoToSocial's `interactionPolicy`

GoToSocial implements a richer `interactionPolicy` for post-level controls:

```json
{
  "@context": [
    "https://www.w3.org/ns/activitystreams",
    "https://gotosocial.org/ns#interactionPolicy"
  ],
  "type": "Note",
  "interactionPolicy": {
    "canReply": {
      "automaticApproval": ["followers"],
      "manualApproval": ["as:Public"]
    },
    "canAnnounce": {
      "automaticApproval": ["followers"],
      "manualApproval": []
    },
    "canLike": {
      "automaticApproval": ["as:Public"],
      "manualApproval": []
    }
  }
}
```

**Characteristics:**
- Audience-based: can target `as:Public`, `followers`, specific actors, or collections
- Two-tier approval: `automaticApproval` vs `manualApproval`
- More complex but more expressive
- Aligned with FEP-044f consent-based interaction patterns

#### Comparison

| Aspect | Pixelfed `capabilities` | GoToSocial `interactionPolicy` |
|--------|-------------------------|--------------------------------|
| Complexity | Simple | Moderate |
| Audience targeting | Public only | Public, followers, specific actors, collections |
| Approval workflow | No | Yes (auto vs manual) |
| Disable action | `null` | Empty arrays |
| Namespace | `pixelfed:` | `gotosocial:` |
| Extensibility | Limited | High |

**Recommendation**: We prioritise GoToSocial's `interactionPolicy` pattern as it:
- Supports the nuanced permissions Bonfire's boundaries system provides
- Aligns with FEP-044f's consent vocabulary (as implemented in Mastodon and others)
- Can degrade gracefully (implementations can ignore `manualApproval` if unsupported)
- Is already documented and gaining adoption

### Proposed `interactionPolicy` property on Group actors

A `interactionPolicy` property on Group actors (and on activities/object related to actors), containing sub-policies for each action type:

```json
{
  "@context": [
    "https://www.w3.org/ns/activitystreams",
    "https://gotosocial.org/ns#interactionPolicy"
  ],
  "type": "Group",
  "id": "https://example.org/groups/1",
  "name": "Example Group",
  "interactionPolicy": {
    "canFollow": {
      "automaticApproval": ["as:Public"],
      "manualApproval": []
    },
    "canJoin": {
      "automaticApproval": ["as:Public"],
      "manualApproval": []
    },
    "canInvite": {
      "automaticApproval": ["followers", "attributedTo"],
      "manualApproval": []
    },
    "canRead": {
      "automaticApproval": ["as:Public"],
      "manualApproval": []
    },
    "canPost": {
      "automaticApproval": ["followers"],
      "manualApproval": ["as:Public"]
    },
    "canReply": {
      "automaticApproval": ["followers"],
      "manualApproval": []
    },
    "canLike": {
      "automaticApproval": ["as:Public"],
      "manualApproval": []
    },
    "canAnnounce": {
      "automaticApproval": ["attributedTo"],
      "manualApproval": ["followers"]
    },
    "canModerate": {
      "automaticApproval": ["attributedTo"],
      "manualApproval": []
    },
    "canCurate": {
      "automaticApproval": ["attributedTo"],
      "manualApproval": ["followers"]
    },
    "canGrant": {
      "automaticApproval": ["attributedTo"],
      "manualApproval": []
    },
    "canEdit": {
      "automaticApproval": ["attributedTo"],
      "manualApproval": []
    },
    "canDelete": {
      "automaticApproval": ["attributedTo"],
      "manualApproval": []
    }
  }
}
```

### Sub-Policy Definitions

| Policy | Description | Typical Use |
|--------|-------------|-------------|
| `canFollow` | Who can follow the group (receive updates without membership) | Usually `as:Public` |
| `canJoin` | Who can become a member | Open groups: `as:Public`; Closed: `manualApproval` only |
| `canInvite` | Who can invite others | Members (`followers`) or mods only (`attributedTo`) |
| `canRead` | Who can view group content | Public groups: `as:Public`; Private: `followers` only |
| `canPost` | Who can create new posts/topics | Members, or moderated (public with manual approval) |
| `canReply` | Who can reply to posts | Usually same as `canPost`, or more open |
| `canLike` | Who can like/react to posts | Usually `followers` or `as:Public` |
| `canAnnounce` | Who can boost/share to the group | Often mod-only for curated groups |
| `canModerate` | Who can approve/reject content, manage members | Mods/admins (`attributedTo`) |
| `canCurate` | Who can pin, feature, or organize content | Mods or trusted members |
| `canGrant` | Who can assign roles/permissions to others | Usually owner or `attributedTo` only |
| `canManageAccess` | Who can manage access controls (block/allow users/instances), probably needs a better name | Usually `attributedTo` |
| `canEdit` | Who can edit others' content | Usually mods only |
| `canDelete` | Who can delete others' content | Usually mods only |

### Target Values

Following GoToSocial's pattern:

| Value | Meaning |
|-------|---------|
| `as:Public` | Anyone (including non-members, remote actors) |
| `followers` | Group members (the group's followers collection) |
| `attributedTo` | Moderators/admins (from group's `attributedTo` property) |
| Specific actor URI | Individual actors (e.g., `"https://example.org/users/alice"`) |
| Custom collection URI | Custom role collections (e.g., `"https://example.org/groups/1/curators"`) |
| `members` | Group members collection (if using SWICG pattern, distinct from `followers`) |

#### Limitation: `followers` Conflates Subscription with Membership

FEP-1b12 uses `followers` as the member collection. This conflates two distinct concepts:

| Concept | Purpose | User Intent |
|---------|---------|-------------|
| **Following** (subscription) | Receive updates in feed | "Show me this group's posts" |
| **Membership** (permissions) | Have permissions within group | "I'm part of this community" |

This creates problems:

1. **Non-members can't follow**: A user might want to see public posts without formally joining
2. **Members can't unfollow**: A member might want to stay in the group but mute notifications
3. **Permission confusion**: Following a group automatically grants member permissions

**Alternative: SWICG's Separate `members` Collection**

The SWICG Groups Taskforce proposes using a dedicated `members` collection with `Join`/`Leave` activities:

```json
{
  "type": "Group",
  "id": "https://example.org/groups/1",
  "followers": "https://example.org/groups/1/followers",
  "members": "https://example.org/groups/1/members"
}
```

With this pattern:
- **`Follow`/`Unfollow`** controls subscription (seeing posts)
- **`Join`/`Leave`** controls membership (having permissions)

In `interactionPolicy`, this enables:

```json
"interactionPolicy": {
  "canPost": {
    "automaticApproval": ["members"]
  },
  "canRead": {
    "automaticApproval": ["followers", "members"]
  }
}
```

**Compatibility Approach**

For maximum compatibility:
- Use `followers` as member collection (FEP-1b12 pattern) for basic interoperability
- Optionally expose a separate `members` collection for implementations that support it
- In `interactionPolicy`, `"followers"` remains the safe default that all implementations understand

**Note**: Bonfire's implementation should consider supporting both patterns, using `followers` for federation compatibility while internally distinguishing between subscription and membership states.

### Approval Types

- **`automaticApproval`**: Action succeeds immediately without review
- **`manualApproval`**: Action requires moderator approval (enters queue)

An empty array means the action is not permitted for anyone in that approval type.


### Federation Considerations

1. **Discovery**: Remote servers can fetch the group actor (or a specific post or other object within a group) and read `interactionPolicy` to understand permissions before attempting actions

2. **Graceful degradation**: Servers not understanding `interactionPolicy` can fall back to:
   - FEP-1b12's `Follow`/`Accept` for membership
   - Standard moderation via `attributedTo`
   - Attempting an action which the remote server (home of the group) can reject/ignore (meaning any side effects should only be applied locally if the activity was accepted)

3. **Override at post level**: Individual posts within a group could override group-level policies using GoToSocial-style `interactionPolicy` for finer control

4. **Compatibility with existing specs**:
   - `followers` maps to FEP-1b12 member collection
   - `attributedTo` maps to FEP-1b12 moderator collection
   - `manualApproval` aligns with moderation queue concepts

### Example Scenarios

**Open public group** (anyone can join and post):
```json
"interactionPolicy": {
  "canJoin": { "automaticApproval": ["as:Public"] },
  "canPost": { "automaticApproval": ["followers"] }
}
```

**Moderated group** (anyone can join, posts require approval):
```json
"interactionPolicy": {
  "canJoin": { "automaticApproval": ["as:Public"] },
  "canPost": { "manualApproval": ["followers"] }
}
```

**Private/closed group** (invite-only, members can post freely):
```json
"interactionPolicy": {
  "canJoin": { "manualApproval": ["as:Public"] },
  "canInvite": { "automaticApproval": ["attributedTo"] },
  "canPost": { "automaticApproval": ["followers"] }
}
```

**Announcement group** (mods post, members read-only):
```json
"interactionPolicy": {
  "canJoin": { "automaticApproval": ["as:Public"] },
  "canPost": { "automaticApproval": ["attributedTo"] },
  "canReply": { "automaticApproval": [] }
}
```

---

## Proposed: Group Relationships Vocabulary

Groups often have relationships with other groups - as related communities, equivalent representations across instances, or hierarchical parent/child structures (like Bonfire's channels within groups).

### Related Groups: `alsoKnownAs`

"As a fediverse user, I want to discover groups related to one I'm viewing - whether that's a space for same community on a different instance/platform, or a sibling community on a related topic - so I can find the best place to participate or explore further."

"As a group admin, I want to indicate related groups that members might be interested in, to help with discovery and cross-pollination."

"As a group admin, I want to link my group to its mirror or previous identity on another instance, so that members and remote servers can recognize it as the same community."

The existing ActivityStreams property `alsoKnownAs` can link equivalent or closely related groups.

**Use cases:**
- Similar groups on different instances
- Federated group migration (old → new location)
- Groups that merge or split (though that could also use parent/child links)
- Cross-platform equivalents (e.g., a Lemmy community linked to a Mobilizon events group)

```json
{
  "type": "Group",
  "id": "https://instance-a.org/groups/rust-dev",
  "name": "Rust Development",
  "alsoKnownAs": [
    "https://instance-b.org/groups/rust-programming",
    "https://instance-c.org/communities/rustaceans"
  ]
}
```

Note: should we use something https://schema.org/isRelatedTo to not conflate group migration (i.e. linking two instances of the "same" group) vs linking related but different groups?

### Hierarchical Groups: Parent/Child Relationships

For nested structures like Bonfire's channels within groups, we propose using existing and extended properties:

#### Parent Reference: `context`

The existing `context` property can reference a parent group/channel:

```json
{
  "type": "Group",
  "id": "https://example.org/groups/programming/rust",
  "name": "Rust",
  "context": {
    "type": "Group",
    "id": "https://example.org/groups/programming",
    "name": "Programming"
  }
}
```

**Note:** `context` is already used in FEP-7888 for conversation threading. Using it for group hierarchy is consistent with its semantic meaning ("the context in which this exists").

#### Children Collection: Schema.org `hasPart`

For discovering child groups/channels, we recommend using Schema.org's established `hasPart`/`isPartOf` properties (requires extending the JSON-LD context):

```json
{
  "@context": [
    "https://www.w3.org/ns/activitystreams",
    {"isPartOf": "schema:isPartOf", "hasPart": "schema:hasPart"}
  ],
  "type": "Group",
  "id": "https://example.org/groups/programming",
  "name": "Programming",
  "hasPart": [
    {"type": "Group", "id": "https://example.org/groups/programming/rust", "name": "Rust"},
    {"type": "Group", "id": "https://example.org/groups/programming/python", "name": "Python"},
    {"type": "Group", "id": "https://example.org/groups/programming/go", "name": "Go"}
  ]
}
```

And the child can then reference the parent with `isPartOf`:

```json
{
  "@context": [
    "https://www.w3.org/ns/activitystreams",
    {"isPartOf": "schema:isPartOf"}
  ],
  "type": "Group",
  "id": "https://example.org/groups/programming/rust",
  "name": "Rust",
  "isPartOf": "https://example.org/groups/programming"
}
```

**Note:** Using `context` (as shown above for parent reference) is also valid and aligns with FEP-7888, but `isPartOf` is more explicit about the hierarchical relationship, especially if using `hasPart` too.

**Why Schema.org properties?**
- `hasPart`/`isPartOf` are well-established with clear semantics
- Already used in JSON-LD contexts across the web
- More portable than defining new properties

#### Inheriting Permissions from Parent Group

A channel can optionally reference the parent group's collections in its `interactionPolicy`, allowing permission inheritance:

```json
{
  "@context": [
    "https://www.w3.org/ns/activitystreams",
    {"isPartOf": "schema:isPartOf"},
    "https://gotosocial.org/ns#interactionPolicy"
  ],
  "type": "Group",
  "id": "https://example.org/groups/programming/rust",
  "name": "Rust Channel",
  "isPartOf": "https://example.org/groups/programming",

  "attributedTo": [
    "https://example.org/groups/programming/attributedTo"
  ],
  "followers": "https://example.org/groups/programming/rust/followers",

  "interactionPolicy": {
    "canJoin": {
      "automaticApproval": ["https://example.org/groups/programming/followers"]
    },
    "canPost": {
      "automaticApproval": ["followers"],
      "manualApproval": ["https://example.org/groups/programming/followers"]
    },
    "canModerate": {
      "automaticApproval": ["https://example.org/groups/programming/attributedTo"]
    }
  }
}
```

**Key patterns:**

| Pattern | Example | Meaning |
|---------|---------|---------|
| Own members | `"followers"` | This channel's followers collection |
| Parent members | `"https://example.org/groups/programming/followers"` | Parent group's members can also interact |
| Parent mods | `"https://example.org/groups/programming/attributedTo"` | Parent group's mods can moderate this channel |
| Own mods | `"attributedTo"` | This channel's own moderators |

**Note:** The `attributedTo` of a channel can directly reference the parent's `attributedTo` collection, meaning the channel inherits its moderators from the parent rather than maintaining a separate list.

**Use cases:**
- **Shared membership**: Parent group members automatically gain access to child channels
- **Centralized moderation**: Parent group mods can moderate all child channels
- **Mixed model**: Channel has own members, but parent mods can still moderate
- **Isolated channel**: Channel uses only its own `followers`/`attributedTo` (no parent references)


### Complete Group Actor Example

Combining `interactionPolicy` with relationship properties:

```json
{
  "@context": [
    "https://www.w3.org/ns/activitystreams",
    "https://gotosocial.org/ns#interactionPolicy"
  ],
  "type": "Group",
  "id": "https://example.org/groups/programming/rust",
  "name": "Rust Programming",
  "summary": "A channel for Rust developers",
  "attributedTo": ["https://example.org/users/alice"],
  "followers": "https://example.org/groups/programming/rust/followers",
  "inbox": "https://example.org/groups/programming/rust/inbox",
  "outbox": "https://example.org/groups/programming/rust/outbox",

  "context": {
    "type": "Group",
    "id": "https://example.org/groups/programming",
    "name": "Programming"
  },

  "alsoKnownAs": [
    "https://other-instance.org/communities/rust"
  ],

  "interactionPolicy": {
    "canFollow": { "automaticApproval": ["as:Public"] },
    "canJoin": { "automaticApproval": ["as:Public"] },
    "canInvite": { "automaticApproval": ["followers", "attributedTo"] },
    "canRead": { "automaticApproval": ["as:Public"] },
    "canPost": { "automaticApproval": ["followers"], "manualApproval": [] },
    "canReply": { "automaticApproval": ["followers"] },
    "canLike": { "automaticApproval": ["as:Public"] },
    "canAnnounce": { "automaticApproval": ["attributedTo"], "manualApproval": ["followers"] },
    "canModerate": { "automaticApproval": ["attributedTo"] },
    "canGrant": { "automaticApproval": ["attributedTo"] },
    "canManageAccess": { "automaticApproval": ["attributedTo"] }
  }
}
```

### Cross-Instance Moderation Flows

When moderators are distributed across multiple instances, moderation actions require coordination between the remote moderator's instance and the group's home instance. This section documents how `interactionPolicy` with `manualApproval` handles these scenarios.

#### Alignment with FEP-044f

This flow follows FEP-044f's patterns for consent-based interactions:
- **`interactionPolicy`** with `automaticApproval`/`manualApproval` arrays (GoToSocial namespace)
- **`Accept`/`Reject`** responses to requests

However, unlike FEP-044f's `QuoteAuthorization` stamps, group moderation does **not** need separate authorization objects because:
- The group's home instance is the authority - it verifies permissions via `interactionPolicy` before acting
- Once the group executes the action (e.g., `Undo(Announce)`), that federated activity *is* the proof of authorization
- Third parties don't need to verify authorization separately - they just process the group's outgoing activities normally

This keeps the flow simpler while maintaining the same `interactionPolicy` vocabulary.

#### Scenario: Remote Mod Hides a Post

A moderator (`@mod@instance-b.org`) wants to hide a post that was shared to a group hosted on `instance-a.org`. "Hiding" means removing the group's `Announce` of that post.

**Group's interactionPolicy:**
```json
{
  "interactionPolicy": {
    "canModerate": {
      "automaticApproval": ["https://instance-a.org/users/admin"],
      "manualApproval": ["https://instance-a.org/groups/cooking/moderators"]
    }
  }
}
```

The `moderators` collection includes `@mod@instance-b.org`.

#### Flow 1: Remote Mod Requests Content Removal

**Step 1: Remote mod sends Delete(Announce) to group inbox**

```json
{
  "@context": "https://www.w3.org/ns/activitystreams",
  "id": "https://instance-b.org/activities/delete-announce-123",
  "type": "Delete",
  "actor": "https://instance-b.org/users/mod",
  "object": {
    "type": "Announce",
    "actor": "https://instance-a.org/groups/cooking",
    "object": "https://instance-c.org/posts/spam-post-456"
  },
  "target": "https://instance-a.org/groups/cooking",
  "to": ["https://instance-a.org/groups/cooking"]
}
```

**Step 2: Group's home instance checks policy**

The group server checks if `@mod@instance-b.org` is in:
1. `automaticApproval` for `canModerate` → No → don't auto-process
2. `manualApproval` for `canModerate` → Yes (via moderators collection) → queue for approval

**Step 3: Home instance queues for manual approval**

The request is queued. A notification is sent to actors with automatic moderation approval (e.g., the admin).

**Step 4a: Approval - Accept activity**

If approved by an admin:

```json
{
  "@context": "https://www.w3.org/ns/activitystreams",
  "id": "https://instance-a.org/activities/accept-456",
  "type": "Accept",
  "actor": "https://instance-a.org/groups/cooking",
  "object": "https://instance-b.org/activities/delete-announce-123",
  "to": ["https://instance-b.org/users/mod"]
}
```

The group then processes the deletion and sends `Undo(Announce)` to all followers:

```json
{
  "@context": "https://www.w3.org/ns/activitystreams",
  "id": "https://instance-a.org/activities/undo-announce-789",
  "type": "Undo",
  "actor": "https://instance-a.org/groups/cooking",
  "object": {
    "type": "Announce",
    "id": "https://instance-a.org/activities/announce-original",
    "actor": "https://instance-a.org/groups/cooking",
    "object": "https://instance-c.org/posts/spam-post-456"
  },
  "to": ["https://www.w3.org/ns/activitystreams#Public"],
  "cc": ["https://instance-a.org/groups/cooking/followers"]
}
```

**Step 4b: Rejection - Reject activity**

If rejected:

```json
{
  "@context": "https://www.w3.org/ns/activitystreams",
  "id": "https://instance-a.org/activities/reject-456",
  "type": "Reject",
  "actor": "https://instance-a.org/groups/cooking",
  "object": "https://instance-b.org/activities/delete-announce-123",
  "summary": "Moderation action not approved",
  "to": ["https://instance-b.org/users/mod"]
}
```

#### Flow 2: Using Flag for Content Reports

Alternatively, a remote moderator can use `Flag` to report content, which may be more appropriate when the mod doesn't have direct moderation rights:

**Step 1: Remote mod flags the content**

```json
{
  "@context": "https://www.w3.org/ns/activitystreams",
  "id": "https://instance-b.org/activities/flag-123",
  "type": "Flag",
  "actor": "https://instance-b.org/users/mod",
  "object": [
    "https://instance-c.org/posts/spam-post-456",
    "https://instance-a.org/activities/announce-original"
  ],
  "content": "This post violates group rules: spam/advertising",
  "target": "https://instance-a.org/groups/cooking",
  "to": ["https://instance-a.org/groups/cooking"]
}
```

**Step 2: Group processes Flag based on canFlag policy**

The group checks `canFlag` policy and queues for moderator review if the actor is authorized.

#### Automatic vs Manual Approval Matrix

| Moderator Location | In `automaticApproval` | In `manualApproval` | Result |
|--------------------|------------------------|---------------------|--------|
| Home instance admin | ✅ | - | Action processed immediately |
| Home instance mod | ❌ | ✅ | Queued for admin approval |
| Remote instance mod | ❌ | ✅ | Queued for admin approval |
| Remote instance mod | ❌ | ❌ | Rejected (unauthorized) |
| Any member (not mod) | ❌ | ❌ | Rejected, use Flag instead |

#### Implementation Notes

1. **Pending Queue**: The group's home instance should maintain a queue of pending moderation actions awaiting approval.

2. **Notification**: When an action is queued, actors in `automaticApproval` should be notified (via their inbox or a dedicated moderation collection).

3. **Timeout**: Consider adding a timeout for pending actions (e.g., 7 days) after which they're auto-rejected.

4. **Audit Trail**: Both `Accept` and `Reject` activities should be logged for moderation transparency.

5. **Cascading**: If the removed content had replies, consider whether to cascade the removal or leave orphaned replies.

6. **Alternative: Direct Undo**: If the mod is in `automaticApproval`, they could send `Undo(Announce)` directly (though semantically `Delete` targeting the Announce is clearer for requesting removal of someone else's Announce).

**Legend:**
- ✅ = Implemented/supported
- ⚠️ = Partial/different approach
- ❌ = Not implemented
- ? = Unknown/needs research
- N/A = Not applicable to this spec/platform

---

[1]: https://github.com/swicg/groups/issues/1
[2]: https://github.com/swicg/groups/issues/2
[3]: https://github.com/swicg/groups/issues/3
[4]: https://github.com/swicg/groups/issues/4
[5]: https://github.com/swicg/groups/issues/5
[6]: https://github.com/swicg/groups/issues/6
[7]: https://github.com/swicg/groups/issues/7
[8]: https://github.com/swicg/groups/issues/8
[9]: https://github.com/swicg/groups/issues/9
[10]: https://github.com/swicg/groups/issues/10
[11]: https://github.com/swicg/groups/issues/11
[12]: https://github.com/swicg/groups/issues/12
[13]: https://github.com/swicg/groups/issues/13
[14]: https://github.com/swicg/groups/issues/14
[16]: https://github.com/swicg/groups/issues/16
[18]: https://github.com/swicg/groups/issues/18
[19]: https://github.com/swicg/groups/issues/19
[20]: https://github.com/swicg/groups/issues/20
[21]: https://github.com/swicg/groups/issues/21
[22]: https://github.com/swicg/groups/issues/22
[23]: https://github.com/swicg/groups/issues/23
[fep-1b12]: https://codeberg.org/fediverse/fep/src/branch/main/fep/1b12/fep-1b12.md
[fep-400e]: https://codeberg.org/fediverse/fep/src/branch/main/fep/400e/fep-400e.md
[fep-db0e]: https://codeberg.org/fediverse/fep/src/branch/main/fep/db0e/fep-db0e.md
[fep-7888]: https://codeberg.org/fediverse/fep/src/branch/main/fep/7888/fep-7888.md
[fep-7458]: https://codeberg.org/fediverse/fep/src/branch/main/fep/7458/fep-7458.md
[FEP-044f]: https://codeberg.org/fediverse/fep/src/branch/main/fep/044f/fep-044f.md

