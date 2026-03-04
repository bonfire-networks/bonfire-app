# Bonfire.UI.Posts
![](https://i.imgur.com/XoQvDCW.png)

`Bonfire.UI.Posts` is an extension that includes some User Interfaces (routes, pages and components) for writing and reading posts in Bonfire.

You can customise it by forking, but we recommend creating an extension which uses this one as a dependency, and defines your custom components, views, and/or routes (you can then comment `Bonfire.UI.Posts.Routes` from your top-level Router to use your custom routes and views instead).


### Stack

So far, Bonfire UI extensions are built with the PETALS stack (note that is not a requirement), which means:

- [Phoenix](https://www.phoenixframework.org/)
- [Elixir](https://elixir-lang.org/)
- [TailwindCSS](https://tailwindcss.com/)
- [Alpine.js](https://alpinejs.dev/)
- [LiveView](https://github.com/phoenixframework/phoenix_live_view#readme)
- [Surface](https://surface-ui.org/)

Surface is a server-side rendering component library (built on top of Phoenix and LiveView) that inherits a lot of design patterns from popular JS framework like Vue.js and React, while being almost JavaScript-free compared to common SPAs.


### Scaffolding
The relevant folders are:
- [Components](https://github.com/bonfire-networks/bonfire_ui_posts/tree/main/lib/components): Surface stateless and stateful components.
- [Views](https://github.com/bonfire-networks/bonfire_ui_posts/tree/main/lib/views): The main pages that are rendered when navigating to a specific route
- [Test](https://github.com/bonfire-networks/bonfire_ui_posts/tree/main/test): All the unit tests for the specific module.

### Other resources
- [A blog post that introduces the concept of themeable bonfire apps](https://bonfirenetworks.org/posts/let_thousand_bonfires_bloom/)


## Copyright and License

Copyright (c) 2020 Bonfire, and CommonsPub Contributors

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
