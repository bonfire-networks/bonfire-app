# Bonfire.Fail

An library for [Bonfire](https://bonfire.cafe/) that contains:

- Handling, standardizing, and formatting errors and error messages
- Mapping of error atoms, exceptions, and Changesets to HTTP codes and friendly messages (see https://hexdocs.pm/plug/Plug.Conn.Status.html#code/1-known-status-codes and `Bonfire.Fail.RuntimeConfig` for built-in lists of errors, which you can extend)
- `Bonfire.Fail` error struct (e.g. `%Bonfire.Fail{code: :gateway_timeout, message: "Gateway Timeout", status: 504`)
- `Bonfire.Fail` and `Bonfire.Fail.Auth` exceptions (e.g. `raise Bonfire.Fail, :unauthorized` or `raise Bonfire.Fail.Auth, :needs_login`)

## Handy commands

## Copyright and License

Copyright (c) 2020 Bonfire, VoxPublica, and CommonsPub Contributors

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
