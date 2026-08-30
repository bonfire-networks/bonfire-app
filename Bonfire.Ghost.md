# Bonfire.Ghost

Ghost blog integration for Bonfire. This extension connects your Bonfire instance to a Ghost CMS blog via both the Content API (public posts) and Admin API (members, drafts, etc.).

## Features

- Display Ghost blog posts in your Bonfire instance.
- Backfill existing articles and automatically mirror publish, edit, unpublish, delete, and republish events.
- Filter article imports by Ghost tags and route them into a Bonfire group or topic.
- Embed a federated Bonfire discussion on Ghost articles (`data-canonical-slug` / `data-canonical-id`).
- Provision passwordless Bonfire accounts for eligible Ghost members and staff.
- Link Ghost authors to stable Bonfire profiles for article attribution.
- Sync Ghost membership tiers to Bonfire circles and use them to protect paid articles.
- Gate new account creation by selected Ghost membership tiers.
- Configure and monitor the integration from an administrator-only settings screen.
- Configure credentials through environment variables and feature behavior through instance settings.

For the complete product-facing capability guide, including access semantics and deliberate limitations, see [Ghost + Bonfire features](docs/features.md).

## Configuration

Set these environment variables:

```bash
# Required for posts
GHOST_URL=https://your-blog.ghost.io
GHOST_CONTENT_API_KEY=your_content_api_key_here

# Optional - for member access
GHOST_ADMIN_API_KEY=id:secret_hex
```

### Getting API Keys

1. Go to your Ghost Admin panel
2. Navigate to **Settings -> Integrations**
3. Click **Add custom integration**
4. Give it a name (e.g., "Bonfire")
5. Copy the **Content API Key** for reading public posts
6. Copy the **Admin API Key** for accessing members (format: `id:secret`)

## Usage

Once configured, visit `/ghost` in your Bonfire instance to see your Ghost blog posts.

### Embed comments on Ghost articles

Add this script tag to your Ghost theme's `post.hbs`:

```html
<script
  src="https://your-bonfire.example/js/comments_embed.js?v1.4"
  data-canonical-slug="{{slug}}"
></script>
```

- `data-canonical-slug` — Ghost post slug (deduplicates via URL; `data-canonical-id` for Ghost ID)

Loading the embed is **read-only**: it displays the thread of an article already imported by the
webhook or the historical backfill, and never imports the article itself. Make sure your blog's
origin is listed in the instance's `IFRAME_ALLOWED_ORIGINS` env var — it is required for the
iframe to render at all (CSP `frame-ancestors`), and it is also what authorises a guest-loaded
*generic* (non-Ghost, `data-media-uri`-only) embed to create a bare thread anchor on first visit.

### Who an imported article belongs to, and where it goes

The embed runs on your blog, so **anyone** can craft its iframe URL. It therefore accepts no
attribute that chooses a post's author, audience or destination — those are decided by the
instance, in **Ghost settings**, and only apply through the trusted import paths (webhook and
backfill):

| Setting | Replaces the old attribute | What it does |
|---|---|---|
| Import author (`auto_import_as`) | `data-creator` | Fallback identity used when the Ghost article author cannot be resolved. Without either a resolvable Ghost author or this fallback, no thread is created. |
| Post into group (`post_into_group`) | `data-group-id` | The group/topic imported articles are posted into. |
| Require topic (`require_topic`) | `data-require-topic` | Only import when the article's primary tag matches a Bonfire topic. |
| — (derived from Ghost `visibility`) | `data-boundary` | Public/members/paid articles get their audience from Ghost itself; paid articles are `:see`-only with `:read` gated to the `ghost_tier:*` circles. |

> **Upgrading:** `data-creator`, `data-boundary`, `data-group-id`, `data-to-circles` and
> `data-require-topic` are now **ignored** (they let a visitor forge a post's author, or publish a
> paid article publicly). Old snippets keep working — the params are just dropped, with a warning
> logged — but if your theme relied on `data-group-id` or `data-require-topic`, set the equivalent
> instance setting above or that behaviour is silently lost.

### Programmatic Access

Use `Bonfire.Ghost.client/0` or `Bonfire.Ghost.admin_client/0` to get a client, then call the underlying API modules directly:

```elixir
# Check if configured
Bonfire.Ghost.configured?()       # Content API
Bonfire.Ghost.admin_configured?() # Admin API

# --- Content API (public posts) ---
{:ok, c} = Bonfire.Ghost.client()

Bonfire.Ghost.API.list_posts(c, limit: 5)
Bonfire.Ghost.API.get_post_by_slug(c, "my-post-slug")
Bonfire.Ghost.API.get_settings(c)

# --- Admin API (members, requires admin_api_key) ---
{:ok, c} = Bonfire.Ghost.admin_client()

Bonfire.Ghost.AdminAPI.list_members(c, limit: 100, include: "labels,newsletters,subscriptions")
Bonfire.Ghost.AdminAPI.list_members(c, filter: "status:paid")
Bonfire.Ghost.AdminAPI.get_member(c, "member-id-here")
Bonfire.Ghost.AdminAPI.get_member_by_email(c, "user@example.com")
Bonfire.Ghost.AdminAPI.list_tiers(c)
Bonfire.Ghost.AdminAPI.list_newsletters(c)
```


## Copyright and License

Copyright (c) 2025 Bonfire Contributors

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
# bonfire_ghost
