# Iconify for Phoenix

Phoenix helpers for using 100,000+ SVG icons from 100+ icon sets compiled by [Iconify](https://icon-sets.iconify.design) (visit that site to browse the sets available and preview the icons)

It copies only the icons you use from the iconify library into your project, preparing them on-the-fly when you first use an icon in a view or component (either at compile time if using the Surface component, or on the first run during development).

It can be configured to embed the icons one of three ways:

- `css` (default): generate a single CSS file containing SVGs of all the icons used
- `img` (default for emojis): to create SVG files in your static assets, used to be included with `img` tags and loaded over HTTP (you may want to include [svg-inject](https://github.com/iconfu/svg-inject) on your site to enable styling of the SVGs, e.g. to change their colour)
- `inline`: to generate a Phoenix Component for each icon used, used to embed the icons as `svg` tags inline in the HTML of your views (meaning the SVG will be included in LiveView diffs)
- `set`: to generate an SVG sprite set for each family, and reference icons with a `use` tag inside of inline SVGs.

There is also an optional integration of [phoenix_live_favicon](https://github.com/BartOtten/phoenix_live_favicon) so you can set an icon (or emoji) as favicon on a page with `Iconify.maybe_set_favicon(socket, icon_name_or_emoji)`.

## Installation

```elixir
def deps do
  [
    {:iconify_ex, "~> 0.1.0"}
  ]
end
```

After running `mix deps.get` you need to fetch the latest [iconify icon sets](https://github.com/iconify/icon-sets) by running something like:

```bash
cd deps/iconify_ex/assets && yarn && cd -
```

## Usage

1. Add `import Iconify` in your Phoenix or LiveView module where you want to use it (or just once in the macros in your Web module).

2. Set one of these options in config to choose which approach you want to use (see above for explanations):

- `config :iconify_ex, :mode, :css`
- `config :iconify_ex, :mode, :img`
- `config :iconify_ex, :mode, :inline`
- `config :iconify_ex, :mode, :set`

Along with this `config :iconify_ex, :env, config_env()` so the library knows when to prepare icons (only when not in prod env).

If using CSS mode, you'll need to include the CSS file in your layout (e.g. `<link phx-track-static rel="stylesheet" href={~p"/images/icons/icons.css"} />` in your app's equivalent of `lib/my_app_web/components/layouts/root.html.heex`) and set some default styles that will be applied to all icons, by adding something like this to your app's main CSS (e.g. `assets/css/app.css`):

```css
[iconify] {
  background-color: currentColor;
  -webkit-mask-size: cover;
  mask-size: cover;
  min-width: 0.5rem;
  min-height: 0.5rem;
}
```

> Note: when using the CSS mode, there's sometimes a race condition that adds an icon several times. Until a fix is found you can run something like `sort -u -o icons_dir/icons.css icons_dir/icons.css` to clean up the CSS file.

Other configurations include:

```elixir
config :iconify_ex, :fallback_icon, "heroicons-solid:question-mark-circle" # when an icon is not found
config :iconify_ex, :generated_icon_modules_path, "./lib/web/icons" # for :inline mode
config :iconify_ex, :generated_icon_static_path, "./priv/static/images/icons" # where CSS and images are stored
config :iconify_ex, :generated_icon_static_url, "/images/icons/" # where CSS and images are served from
```

3. In all three cases, usage is the same (meaning you can easily switch between modes at any time) by including a component:

Embed an icon using default classes (copy the icon name from the [iconify website](https://icon-sets.iconify.design)):

```html
<.iconify icon="heroicons:collection-solid" />
```

Specify custom classes:

```html
<.iconify icon="heroicons:collection-solid" class="w-8 h-8 text-base-content" />
```

Or if you use [Surface](https://surface-ui.org), it is highly recommended to use the macro component which means icons will be prepared at compile time rather than runtime:

Add `alias Iconify.Icon` to your Web module, and then:

```html
<#Icon iconify="heroicons:collection-solid" />
```

If your icon is dynamic, you'll still want to use the first form:

```html
<.iconify icon={@my_icon} />
```

**Special handling for Heroicons:** This library supports Heroicons v2 with backwards compatibility for v1 names:

- **v2 naming** (recommended): `heroicons:icon-name` (24px outline), `heroicons:icon-name-solid` (24px solid), `heroicons:icon-name-20-solid` (20px mini), `heroicons:icon-name-16-solid` (16px micro)
- **v1 naming** (backwards compatible): `heroicons-solid:icon-name` (auto-translates to v2 24px solid), `heroicons-outline:icon-name` (auto-translates to v2 24px outline)

