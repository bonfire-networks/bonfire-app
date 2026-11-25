# Widgets on your website

You can show some of your instance's widgets on another website: your team from a circle's members, the posts your instance has pinned to its Spotlight, your community rules, and more. Each one shows what a visitor who isn't signed in would see on your instance, and its links open your instance in a new tab.

## On your instance

Whoever runs your Bonfire instance sets these once.

- `IFRAME_ALLOWED_ORIGINS` (required): the sites allowed to show your widgets, separated by spaces, for example `IFRAME_ALLOWED_ORIGINS="https://your-site.example https://another-site.example"`. It's the same setting as for [comments on your website](./embedded-comments.md), so a site listed for one can show both.
- `CACHE_WIDGET_EMBEDS` (optional): widgets embedded on other sites are cached, so a busy page costs your instance little, and the cache is cleared when a widget's content changes (for example when you pin a post, or add someone to a circle). Set it to `false` to turn this off.

## Add it to a page

Add this where the widget should appear:

```html
<script
  src="https://your-instance.social/js/widget_embed.js"
  data-widget="instance_pinned"
  data-theme="dark"
  async
></script>
```

Only `src` and `data-widget` are required. The widget's frame grows to fit its content.

## Options

Add any of these attributes to the script tag, for any widget:

- `data-theme`: a Bonfire theme name, for example `"dark"` or `"light"`.
- `data-width`: `"full"` to fill the width of the space you put it in, or a maximum width in pixels, for example `"480"` (default: `720`).

## Which widgets

Put the widget's name in `data-widget`. Some take options of their own.

- `instance_pinned`: the Spotlight, the posts your instance has pinned.
  - `data-items`: how many posts show side by side, from 1 to 4 (default: 3).
- `circle_members`: the members of one of your circles, for example for a "Our team" section.
  - `data-circle` (required): the circle's ID. Only members a visitor may see are shown, and nothing at all for a circle visitors can't see.
  - `data-variant`: `"portrait"` for photo tiles (default: a list of names).
- `mods`: your instance's moderators, unless your instance shows them to signed-in people only.
- `community_rules`: your community rules.
- `intro`: your instance's introduction.
- `instance_facts`: your instance at a glance.
- `community_links`: your community links.
- `groups`: your instance's groups.
- `recent_users`: who recently joined.
- `popular_topics`: popular topics.
- `custom_` followed by the custom widget's name, for a custom text widget the instance admins created in the instance settings (**Widgets**).

A widget that only makes sense for someone signed in, such as one listing their own things, can't currently be embedded.

