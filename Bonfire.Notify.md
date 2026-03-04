# Bonfire.Notify

An extension for [Bonfire](https://bonfire.cafe/) that handles:

- Records user notifications
- Sends web push notifications

## Configuration

For Web Push, you need to generate keys: 
`Bonfire.Notify.WebPush.generate_keys_env()`

Then set these env variables:
WEB_PUSH_PUBLIC_KEY 	VAPID public key.
WEB_PUSH_PRIVATE_KEY 	VAPID private key.

## Sample usage

See the tests.
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

---

A portion of this code (specifically the WebPush related modules) have been forked from https://github.com/unstacked/level which comes with “Commons Clause” License Condition v1.0:

License: Apache 2.0 (http://www.apache.org/licenses/LICENSE-2.0.txt)
Licensor: Level Technologies, LLC

The Software is provided to you by the Licensor under the License subject to the following condition.

Without limiting other conditions in the License, the grant of rights under the License will not include, and the License does not grant to you, the right to Sell the Software.

For purposes of the foregoing, “Sell” means practicing any or all of the rights granted to you under the License to provide to third parties, for a fee or other consideration (including without limitation fees for hosting or consulting/ support services related to the Software), a product or service whose value derives, entirely or substantially, from the functionality of the Software. Any license notice or attribution required by the License must also include this Commons Cause License Condition notice.
