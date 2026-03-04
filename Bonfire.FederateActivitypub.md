# Bonfire.Federate.ActivityPub

An extension for [Bonfire](https://bonfire.cafe/) that handles:

- Extensible/configurable tools for translating Bonfire data to/from ActivityStreams
- Bonfire Adapter for the [ActivityPub federation library ](https://github.com/bonfire-networks/activity_pub)

## Testing

There are unit tests both in this repo, and in the activity_pub lib, but they can't cover every possible federation case, so manual testing with e.g. `curl -H "Accept: application/activity+json" -v "http://localhost:4001/pub/actors/my_username" | jq '.'` and by trying out federation flows between instances of Bonfire and other ActivityPub implementation is a must. 

## Handy commands

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
