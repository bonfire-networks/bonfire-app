# Comments on your website (the Telling)

The Telling puts a Bonfire discussion under any page of your website: a blog post, an article, a documentation page. Readers can comment with an account on your Bonfire instance, or reply from their own account on any fediverse server. Each page's discussion is a thread on your instance, so it federates like any other post.

## On your instance

Whoever runs your Bonfire instance sets these once.

- `IFRAME_ALLOWED_ORIGINS` (required): the sites allowed to show the Telling, separated by spaces, for example `IFRAME_ALLOWED_ORIGINS="https://your-blog.example https://another-site.example"`. Without it the Telling doesn't display on your site, and no thread is ever created for a page on a site that isn't listed.
- Import author (optional): the account new threads are posted under, for example your own or a dedicated one for your site. With it, a page's thread is created as soon as the Telling first loads there. Without it, a thread starts when a member of the instance signs in through the Telling on that page, so sign in yourself on each new page before readers arrive. For now it's set as "Default author" in the Ghost settings, which needs the Ghost extension.

## Add it to a page

Add this to the template of the pages that should have comments, where the comments should appear:

```html
<script
  src="https://your-instance.social/js/comments_embed.js"
  data-theme="dark"
  data-mode="nested"
  async
></script>
```

Only `src` is required. The thread defaults to the current page's address, so on most sites the tag above is all you need.

## Options

Add any of these attributes to the script tag.

Which thread it shows:

- `data-media-uri`: find or create the thread for this address (default: the current page's address).
- `data-canonical-slug` / `data-canonical-id`: find a thread already imported for this post's slug or ID on your own site (for example a Ghost post). Loading the Telling never imports the post itself.
- `data-post-id`: show a specific Bonfire thread by its ID.
- `data-published-at`: the page's publication date, as `YYYY-MM-DD` (midnight UTC) or a date and time with seconds and a timezone, for example `2026-11-02T14:30:00Z` or `2026-11-02T14:30:00+01:00`. Backdates a newly created thread, so an older article doesn't jump to the top of feeds. Future dates are ignored, and so is a time without seconds or without a timezone (the thread is then simply not backdated).

How it looks and behaves:

- `data-theme`: a Bonfire theme name, for example `"dark"` or `"light"`.
- `data-mode`: `"flat"` or `"nested"` (default: the instance or user setting).
- `data-sort-by` / `data-sort-order`: initial sort (`"latest_reply"`, `"reply_count"`, `"boost_count"`, `"like_count"`, `"popularity_score"` or `"newest"`) and direction (`"asc"` or `"desc"`).
- `data-auth-mode`: `"remote"` makes the Reply button for logged-out readers send them to reply from their own fediverse account, instead of signing in to your instance. On an instance that is invite-only and which federates, this is the default.
- `data-token-max-age`: hours before a reader's stored sign-in is treated as stale and they're asked to sign in again (default `720`, 30 days). The server enforces a maximum.

## Help the fediverse find your thread

The reply button already sends fediverse readers to the thread, but if someone pastes your page's address into the search box of their own server instead, that server reads your page without running the script, so it can't see the Telling. Add this line to the `<head>` of your page template to point it at the thread:

```html
<link rel="alternate" type="application/activity+json"
  href="https://your-instance.social/comments/embed?media_uri=MEDIA_URI">
```

Replace `MEDIA_URI`, URL-encoded, with the same address the Telling uses for the thread: your `data-media-uri` if you set one, otherwise the page's full address (use your site builder's variable for it).

Bonfire servers follow this link to the thread. If your instance has an import author set (see above) and your site is in its allowed origins, the thread is created the first time the Telling loads on the page, or a fediverse server looks it up through this link.

Mastodon only follows a link that is the thread's exact address, not one that redirects there. If your site has a build step, fetch the link above with the header `Accept: application/activity+json`, and put the address it redirects to in the tag instead. That exact address works on Mastodon and Bonfire alike.

## Ghost

The Ghost extension imports your articles and has its own setup. See the `bonfire_ghost` extension's README.
