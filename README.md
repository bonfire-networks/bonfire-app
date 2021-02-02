## Bonfire 

This app is part of the [Bonfire](https://bonfire.cafe/) ecosystem and bundles the following extensions:

- [Bonfire:Common](https://github.com/bonfire-ecosystem/bonfire_common) - common utils
- [Bonfire:Me](https://github.com/bonfire-ecosystem/bonfire_me) - accounts, user profiles, posts, feeds, activities...
- [Bonfire:UI:Social](https://github.com/bonfire-ecosystem/bonfire_ui_social) - frontend components for social activities 

## Handy commands

* `mix cpub.deps.update` - updates commonspub dep versions
* `mix cpub.deps.clean` - cleans the compiled deps so config is reread
* `mix cpub.deps` - both of the above

If using Docker, just replace `mix ` with `make mix-` in the above commands, so for example `mix cpub.deps` becomes `make mix-cpub.deps`.

## Copyright and License

Copyright (c) 2020 Bonfire Contributors

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
