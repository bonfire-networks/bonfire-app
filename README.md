## Bonfire 

This app is part of the [Bonfire](https://bonfire.cafe/) ecosystem and bundles the following extensions:

- [Bonfire:Common](https://github.com/bonfire-ecosystem/bonfire_common) - common utils
- [Bonfire:Me](https://github.com/bonfire-ecosystem/bonfire_me) - accounts, user profiles...
- [Bonfire:Social](https://github.com/bonfire-ecosystem/bonfire_social) - feeds, activities, posts, boosting, flagging, etc...
- [Bonfire:Boundaries](https://github.com/bonfire-ecosystem/bonfire_boundaries) - define circles and associated privacy or permissions
- [Bonfire:UI:Social](https://github.com/bonfire-ecosystem/bonfire_ui_social) - reusable frontend components for social activities 
- [Bonfire:Federate:ActivityPub](https://github.com/bonfire-ecosystem/bonfire_federate_activitypub) - federates activities with ActivityPub to participate in the fediverse

## Handy commands

* `make update` - updates the app + extensions (use `make d-update` if using docker)
* `mix bonfire.deps.clean` - cleans Bonfire extensions so they get recompiled (necessary after changing config such as in `config/bonfire_data.exs`)


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
