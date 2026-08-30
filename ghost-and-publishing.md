# Ghost ↔ Bonfire identity & publishing

How people in Ghost (members and staff) map to Bonfire accounts and profiles,
what happens when emails change, and how to repair identities that split before
the identity link existed.

## The identity model

One row per person in `bonfire_ghost_identity` (see `Bonfire.Ghost.Identities`):

| column | meaning |
|---|---|
| `account_id` | the local account (primary key — the identity anchor) |
| `user_id` | the author/attribution profile, once known |
| `ghost_staff_id` | Ghost staff-user ID (authors/editors/admins) |
| `ghost_member_id` | Ghost member ID (subscribers) |
| `ghost_email` | last Ghost email successfully reconciled with the local account |

Ghost keeps staff and members as **separate entities with separate ID spaces**,
and the same human can be both — both IDs live on the same row, so both Ghost
records converge on one Bonfire account.

Every provisioning path (sign-in, member webhooks, the admin "Sync members"
backfill, article imports) resolves **ID-first, email as fallback**, and writes
the link back — so identities provisioned before the table existed get linked
on their next touch.

### Email changes — both directions

- **Changed in Ghost** (staff or member): the next sign-in, webhook, backfill or
  import matches by Ghost ID and **updates the Bonfire account's email** to
  follow — no duplicate identity, sign-in works with the new address
  immediately. If the new address already belongs to a *different* Bonfire
  account, the change is NOT applied (logged as a warning) — merging two
  accounts is an admin decision. The previous `ghost_email` marker is retained,
  so once the conflict is resolved a later sync can retry the change.
- **Changed in Bonfire** (the person sets their own address): the link is
  ID-based, so nothing breaks — and sync **respects the local choice**: it only
  follows Ghost's email while the local one still tracks what Ghost last had
  (`ghost_email`). A locally-customized address is never clobbered back.
- Email lookups are **case-insensitive** (exact match preferred), so case
  variance can neither hide nor split an account.

### Attribution

Article imports resolve the author by `ghost_staff_id` → linked `user_id`
first, so an author's articles stay attributed to the same profile forever —
across email changes, and on accounts with several profiles the *linked* author
profile wins, not whichever profile happens to come first.

### Sign-in

One flow for everyone (`/login/forgot-password`): local account lookup first, then Ghost member lookup (with the tier gate). An allowed member is checked for a matching Ghost staff record before member provisioning; this matters when the same person is both, because the staff ID can reconnect a freshly changed email to the existing author before the member ID is attached to that same account. Staff bypass the tier gate; only staff *suspended* in Ghost are refused. Established accounts with profiles always get their magic link without consulting Ghost. A profileless account may invoke the provider's reconciliation hook so an empty fork can be repaired before the link is issued. Unknown emails get the same neutral response — no account enumeration.

If an active staff record has no identity link yet, its identity link points to a profileless fork, or a separately-created profileless fork already holds Ghost's new email, a conservative claim step reconnects it to the stranded account. The staff slug must match the account's single profile, and the account must carry Ghost provisioning evidence or that profile must have authored an imported object from the configured Ghost site. For legacy profiles that predate both markers, an already-linked empty fork is sufficient evidence only when its own stash has the exact Ghost staff ID, kind and normalized name, the older profile has the same normalized name, and the account/email chronology matches the split. A conflicting profileless account is only quarantined when its own Ghost provisioning marker contains the same staff ID.

### The tier gate

Admin settings → Ghost → **Membership tiers** toggles which tiers may have an
account (`[:bonfire_ghost, :required_tier, <slug>]`, instance scope). **No tier
toggled on = gate off**, i.e. any Ghost member is allowed.

The gate lives in `Bonfire.Ghost.TierGate` and is enforced inside
`Sync.Members.provision_from_ghost_member/2`, so it holds on *every* path that
can create an account — gated sign-in, the `member.added`/`member.edited`
webhooks, and the "Sync members" backfill alike. Refused members return
`{:skip, :tier_not_allowed}` (the backfill counts them as `skipped`, the webhook
job cancels rather than retries).

That placement is load-bearing. Established local accounts remain outside the provisioning gate; the profileless-account reconciliation hook repairs identity links but does not create a new account. Until 2026-07-21 the webhook and backfill provisioned everyone, and a free Ghost signup therefore got a working jacobin.social login on a paid-tier-only instance. Never add a provisioning path that skips `provision_from_ghost_member/2`.

Staff bypass the gate (separate Ghost entity, no tiers); `skip_tier_gate: true`
bypasses it deliberately. A payload with no `tiers` key is resolved against the
Ghost API rather than read as "no tiers", and fails **closed** if unreachable.

Testing note: tests that write `required_tier` MUST restore
`Application.get_env(:bonfire_ghost, :required_tier)` in `on_exit`. Instance
settings leak between test files through app config, and a leaked gate now
refuses provisioning across the whole suite.

### Ghost staff statuses (why "locked" is not offboarding)

Per Ghost's own `models/user.js`:

| status | meaning | may sign into Bonfire? |
|---|---|---|
| `active`, `warn-1`…`warn-4` | normal; `warn-*` are failed-login warnings | yes |
| `locked` | "imported users, they get a random password" — never set a Ghost password | **yes** |
| `inactive` | owner-before-setup, and **suspended** users | no |

Bonfire signs people in with its own magic link and never touches Ghost
credentials, so "has no Ghost password" says nothing about whether someone may
have an account here. Treating `locked` as offboarded turned away 1522 of
jacobin.social's 1535 contributors — every bulk-imported author — who were sent
the "buy a subscription" email instead of reaching their own author profile.
Suspension (`inactive`) remains the one Ghost-side control that withholds access.

### Revocation stance

Ghost status governs **granted permissions, not accounts**: a member deletion
or cancellation only removes `ghost_tier:*` circles (access to gated content);
their account, profile, posts and follows remain theirs. Staff are treated the
same — suspension/locking in Ghost only blocks *new* provisioning at sign-in.
Nobody's identity or federated content disappears because their relationship to
the publication changed.

## Operational notes

### After deploying this feature to an existing instance

Run once, in this order:

1. Deploy (the `bonfire_ghost_identity` migration runs).
2. Admin settings → Ghost → **"Sync members"**. The backfill walks tiers → active staff → members and writes identity rows keyed on everyone's *current* emails. Staff and member pagination order by both creation time and ID because bulk imports often give many records the same timestamp; removing that tie-breaker causes Ghost page boundaries to repeat some records and skip others.
3. Only THEN change emails in Ghost (e.g. give contributor profiles their real
   addresses). The links recorded in step 2 make every change follow instead of
   fork.

New authors need no manual step: their identity row is written at first article
import (or first sign-in), and from then on everything follows.

### Accounts created before the tier gate was enforced everywhere

Closing the hole stops *new* ungated accounts; it does not remove the ones the
webhook/backfill already made. Existing accounts are never gated at sign-in (the
local lookup wins), so audit them once in a production IEx console:

```elixir
alias Bonfire.Ghost.{AdminAPI, Ghost, TierGate}
alias Bonfire.Me.Accounts
repo = Bonfire.Common.Repo
import Ecto.Query

{:ok, c} = Bonfire.Ghost.admin_client()

# every local account whose Ghost member record fails the current gate
repo.all(from(e in Bonfire.Data.Identity.Email, select: e.email_address))
|> Enum.filter(fn email ->
  case AdminAPI.get_member_by_email(c, email, include: "tiers") do
    {:ok, %{"members" => [m | _]}} -> not TierGate.allowed?(m, client: c)
    _ -> false   # not a member (staff / local-only account) — leave alone
  end
end)
```

Then decide per person — deleting an account is a real deletion (posts, follows,
federated identity), so the "Revocation stance" above argues for doing it only
where the account was clearly created in error and is unused.

### Repairing identities that split BEFORE this feature (e.g. duplicated author profiles)

Symptoms: two profiles for one person (`@Author` + `@AuthorContributor`-style),
the original stranded on an unreachable email, new articles attributed to the
takeover profile.

In a production IEx console:

```elixir
alias Bonfire.Me.{Accounts, Users}
alias Bonfire.Ghost.Identities
alias Bonfire.Data.Identity.Email
repo = Bonfire.Common.Repo

# 1. DIAGNOSE — which accounts/emails sit behind the two profiles?
for username <- ["OleRauch", "OleRauchContributor"] do
  {:ok, u} = Users.by_username(username)
  u = repo.maybe_preload(u, accounted: [account: [:email]])
  %{username: username, account: u.accounted.account_id,
    email: u.accounted.account.email.email_address}
end

# 2. RE-KEY the ORIGINAL author account to the email the person really uses.
#    (If that email currently sits on the takeover account, first move the
#    takeover account to a throwaway address the same way.)
{:ok, original} = Users.by_username("OleRauch")
account = repo.maybe_preload(original, accounted: [account: [:email]]).accounted.account

{:ok, _} =
  account.email
  |> Email.changeset(%{email_address: "rauch@jacobin.de"}, must_confirm?: false)
  |> repo.update()

# 3. LINK the Ghost IDs to the original account + author profile
#    (find the ids in Ghost admin, or via AdminAPI.get_user_by_email):
Identities.link(account,
  staff_id: "<ghost staff id>",
  member_id: "<ghost member id, if they are also a member>",
  user: original,
  ghost_email: "<the email currently in Ghost>"
)
```

From then on the person signs in with their email and lands in the original
author profile; imports attribute to it.

**Articles wrongly attributed to the takeover profile:** attribution is fixed
at post creation, so the clean fix is to delete the wrongly-attributed post and
re-import the article (webhook re-send or the article backfill) — with the link
in place it re-creates under the right author. NB this drops any comments
already attached to the wrong post's thread, so decide per article.

**The takeover account/profile afterwards:** either keep it (the person can use
it as a personal profile — consider moving it under their main account, or the
`Bonfire.Me.SharedUsers.add_account/3` team-profile mechanism if several people
should co-manage an editorial identity) or delete it.
