## Bonfire + ValueFlows

This app is part of the [Bonfire](https://bonfirenetworks.org/) and [ValueFlows](http://valueflo.ws/) ecosystems and bundles the following extensions:

- [Bonfire:Common](https://github.com/bonfire-networks/bonfire_common) - common utils
- [Bonfire:Me](https://github.com/bonfire-networks/bonfire_me) - accounts, user profiles...
- [Bonfire:Social](https://github.com/bonfire-networks/bonfire_social) - feeds, activities, posts, boosting, flagging, etc...
- [Bonfire:UI:Social](https://github.com/bonfire-ecosystem/bonfire_ui_social) - interface for basic social activities 
- [Bonfire:Boundaries](https://github.com/bonfire-networks/bonfire_boundaries) - define circles and associated privacy or permissions
- [Bonfire:Federate:ActivityPub](https://github.com/bonfire-networks/bonfire_federate_activitypub) - federates activities with ActivityPub to participate in the fediverse
- [Bonfire:Geolocate](https://github.com/bonfire-ecosystem/bonfire_geolocate) - places
- [Bonfire:Quantify](https://github.com/bonfire-ecosystem/bonfire_quantify) - units & measures
- [Bonfire:ValueFlows](https://github.com/bonfire-ecosystem/bonfire_valueflows) - economic activities with ValueFlows
- [Bonfire:UI:ValueFlows](https://github.com/bonfire-networks/bonfire_ui_social) - reusable frontend components for economic activities 
- [Bonfire:ValueFlows:Observe](https://github.com/bonfire-ecosystem/bonfire_valueflows_observe) - observation of economic resources
- [Bonfire:API:GraphQL](https://github.com/bonfire-ecosystem/bonfire_api_graphql) - a GraphQL client API
- [Bonfire:RecyclApp](https://github.com/bonfire-ecosystem/bonfire_recyclapp) - interface for ValueFlows-based recycling apps

## Handy commands

* Upgrade the app + extensions: `make update`  (or `make d-update` if using docker)
* Wipe clean Bonfire extensions builds so they get recompiled: `mix bonfire.deps.clean` (necessary after changing config such as in `config/bonfire_data.exs`)
* Clone a git dep and use the local version, eg: `make dep-clone-local dep="bonfire_me" repo=https://github.com/bonfire-networks/bonfire_me` 
* Automatically commit and push all your changes to local forks (caution, here be dragons!): `make bonfire-push-all-update` 
* Migrate DB when the app is running: `Bonfire.Repo.ReleaseTasks.migrate`
* More handy commands: `make help` and `mix help`


## Copyright and License

Copyright (c) 2021 Bonfire Contributors

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
