<!--
SPDX-FileCopyrightText: 2026 Bonfire Networks <https://bonfirenetworks.org/contact/>

SPDX-License-Identifier: AGPL-3.0-only
SPDX-License-Identifier: CC0-1.0
-->

# Themes and appearance

Bonfire supports three ways to change its appearance:

- **Instance custom theme:** an administrator changes colours and corner radii from the Bonfire interface. The values are stored in the instance settings and applied to that instance.
- **Configured custom-theme default:** an operator or flavour maintainer seeds the instance custom palette from Elixir configuration. Administrators can override those defaults through the interface.
- **Named flavour theme:** a flavour maintainer defines a reusable theme in CSS and includes its name in the flavour configuration. It is compiled with the application.

Bonfire does not load DaisyUI's stock themes, accept arbitrary CSS through the theme editor, or fall back to another DaisyUI theme when a name is missing. Every named theme must follow Bonfire's current token contract.

## Choose an instance theme

Sign in as an instance administrator and open **Settings → Default User Preferences → Appearance → Theme**. The page is also available directly at `/settings/instance/preferences/appearance`.

The theme mode controls when the configured themes are used:

| Mode | Behaviour |
| --- | --- |
| **Use dark** | Always uses the selected dark theme. |
| **Use light** | Always uses the selected light theme. |
| **Use system** | Switches between the selected light and dark themes with the visitor's device preference. |
| **Use custom** | Uses the selected dark theme as a base and applies the instance's stored custom overrides. |

The cards under **Light mode theme** and **Dark mode theme** select a named theme for each mode. Use **Preview** to inspect a theme without selecting it, then **Choose** to make it the instance default for that mode.

People who have not chosen their own mode see the instance setting. This includes guests and signed-in people using **Follow instance theme**. A person's own light, dark, system, or custom choice takes precedence for that person.

## Customise a theme for one instance

Choose **Use custom** to open the custom-theme editor. The editor starts from the instance's selected dark theme and stores only the values you change. A control labelled **Inherited** continues to use its value from that base theme.

The editor exposes:

- 20 colour tokens for base surfaces, primary, secondary, accent, neutral, info, success, warning, and error colours, including their content colours;
- corner radii for boxes, fields, and selectors.

Select a colour, choose its new value, and press **Apply**. Changes are saved to the instance palette and become visible to guests and people following the instance theme.

The picker supports opaque three- and six-digit hex colours; alpha hex values are unsupported.

Use **Reset** on a colour or **Base** on a radius to remove only that override. Use **Reset all** to remove the complete stored instance palette. Values then inherit from the selected base theme, subject to the [configured defaults below](#set-a-default-custom-palette-in-configuration).

When choosing colours, check text and controls across the interface for sufficient contrast. In particular, test every `*-content` colour against its matching background colour.

## Choose your own theme

Open your personal Appearance settings at `/settings/user/preferences/appearance`. New users follow the instance theme by default. Your changes here affect only your own interface.

Choose **Use light**, **Use dark**, or **Use system** to override the instance's mode. You can also choose your own named themes from the light and dark cards. Until you choose a different named theme, the instance's selection applies.

Choose **Use custom** to edit your own colours and corner radii with the same controls described above. Your selected dark theme is the base; unset values inherit from it. Your custom overrides are kept separate from the instance's custom palette, so choosing this mode does not copy or merge the administrator's custom colours.

**Reset**, **Base**, and **Reset all** remove personal custom overrides while keeping custom mode selected. To return to the instance's mode and named themes, choose **Follow instance theme**. Your saved custom colours and radii are retained for when you choose **Use custom** again.

## Set a default custom palette in configuration

An operator or flavour maintainer can seed the instance custom palette in `config/*.exs`. This uses the same `custom_instance` palette as the administrator interface; it does not create a new named theme or a new card in the theme picker.

```elixir
import Config

config :bonfire, :ui,
  theme: [
    preferred: :custom,
    instance_theme: "dark",
    custom_instance: %{
      "color-primary" => "#e63027",
      "color-primary-content" => "#ffffff",
      "color-base-100" => "#fff7f7",
      "radius-box" => "0.5rem"
    }
  ]
```

`preferred: :custom` activates the instance custom mode. `instance_theme` selects the named dark/base theme used for every token that is not present in `custom_instance`.

Configuration may set any of the 28 allowlisted custom-theme tokens: the 20 colour tokens, three radius tokens, `size-selector`, `size-field`, `border`, `depth`, and `noise`. Unknown keys and unsafe values are not emitted as CSS. Configuration cannot use this map to add arbitrary CSS variables.

The configured palette is the deployment default. Instance values saved through the administrator interface take precedence. Reset removes the stored override and its current in-memory value; its configured default returns when configuration is reloaded, such as on restart. Omit `custom_instance` from configuration when **Reset** should always return directly to the named base theme.

Restart Bonfire after changing runtime configuration. Configuration baked into a release requires rebuilding that release. Changing only the `custom_instance` map does not itself require CSS compilation.

## Add a named theme to a flavour

A named theme is part of a flavour's source code. It requires both a CSS definition and a configuration entry:

1. `extensions/my_flavour/themes/theme.css` defines the theme values that are compiled.
2. `extensions/my_flavour/config/my_flavour.exs` lists the theme under the light or dark picker and may make it the default.

The configuration list does not define any CSS values. A name that appears in configuration without a matching compiled CSS definition will be shown in the picker but will not render correctly.

### 1. Define the complete theme

Start from a current Bonfire `light`, `dark`, or maintained flavour theme rather than a stock DaisyUI theme. Give every theme a unique lowercase name and define the complete supported token set.

```css
/* extensions/my_flavour/themes/theme.css */
@plugin "daisyui/theme" {
  name: "my-theme";
  default: false;
  prefersdark: false;
  color-scheme: light;

  --color-base-100: oklch(100% 0 0);
  --color-base-200: oklch(98.5% 0.002 250);
  --color-base-300: oklch(97% 0.003 250);
  --color-base-content: oklch(28% 0.012 250);

  --color-primary: #4169e1;
  --color-primary-content: #ffffff;
  --color-secondary: oklch(93% 0.006 250);
  --color-secondary-content: oklch(38% 0.012 250);
  --color-accent: oklch(58% 0.08 245);
  --color-accent-content: #ffffff;
  --color-neutral: oklch(30% 0.012 250);
  --color-neutral-content: oklch(97% 0 0);

  --color-info: oklch(52% 0.11 235);
  --color-info-content: #ffffff;
  --color-success: oklch(52% 0.12 150);
  --color-success-content: #ffffff;
  --color-warning: oklch(64% 0.13 85);
  --color-warning-content: oklch(24% 0.04 85);
  --color-error: oklch(57% 0.19 25);
  --color-error-content: #ffffff;

  --radius-selector: 2rem;
  --radius-field: 2rem;
  --radius-box: 0rem;
  --size-selector: 0.25rem;
  --size-field: 0.25rem;
  --border: 1px;
  --depth: 0;
  --noise: 0;

  --spacing-page-header: 64px;
  --text-display: clamp(20px, 18.6px + 0.36vw, 20px);
  --elevation-modal: 0 0 0 1px oklch(0% 0 0 / 0.06), 0 24px 48px -12px oklch(0% 0 0 / 0.18);
  --elevation-popover: 0 2px 6px -2px oklch(0% 0 0 / 0.08), 0 12px 24px -8px oklch(0% 0 0 / 0.14);
}
```

Replace the example values with the flavour's design tokens. This example uses Bonfire's shared `dark` theme for dark mode.

### 2. Add the theme to the picker

List only names that exist in the flavour's `themes/theme.css` or Bonfire's shared `light` and `dark` definitions.

```elixir
# extensions/my_flavour/config/my_flavour.exs
import Config

config :bonfire, :ui,
  themes_light: ["my-theme", "light"],
  themes_dark: ["dark"],
  theme: [
    instance_theme_light: "my-theme",
    instance_theme: "dark"
  ]
```

`themes_light` and `themes_dark` control which cards appear in the picker. `instance_theme_light` and `instance_theme` select the flavour defaults. Despite its historical name, `instance_theme` is the dark theme and the base used by custom palettes.

To add a custom dark theme, define a second complete CSS block with a unique name and `color-scheme: dark`, then use that name in `themes_dark` and `instance_theme`.

### 3. Build and verify the flavour

From the Bonfire application root:

```sh
just prepare-flavour-theme my_flavour
cd extensions/bonfire_ui_common/assets
yarn build.css
```

Preparation copies the selected flavour's CSS into the ignored `assets/css/current_flavour_theme.css`. Edit the flavour source, not that generated file. Flavours without theme CSS produce an empty file and use the shared themes.

The CSS build ends with a theme-contract message listing the shared themes and those in the prepared flavour CSS. For this example:

```text
Theme contract verified: dark, light, my-theme
```

The contract rejects missing or unexpected compiled theme selectors. It does not check picker configuration, token completeness, or whether the prepared file belongs to the intended flavour.

To test the complete application configuration, switch the application to the flavour, finish setup, and restart the development server:

```sh
cd ../../..
just flavour my_flavour
just setup
just dev
```

Reopen the appearance settings after the restart. Confirm that only the expected names appear, preview each theme, and test light, dark, system, and custom modes.

We'll gradually add themes back as they are adapted to Bonfire's current styling, and expand the custom-theme options to let you configure more CSS tokens as the interface evolves.
