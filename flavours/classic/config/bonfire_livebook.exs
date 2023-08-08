# SPDX-FileCopyrightText: 2023 Bonfire contributors <https://github.com/bonfire-networks/bonfire-app/graphs/contributors>
#
# SPDX-License-Identifier: AGPL-3.0-only

import Config

config :bonfire_livebook,
  disabled: false,
  base_url_path: "/livebook/"

# Sets the default authentication mode to token
config :livebook, :authentication_mode, :token

# Sets the default runtime to ElixirStandalone.
# This is the desired default most of the time,
# but in some specific use cases you may want
# to configure that to the Embedded or Mix runtime instead.
# Also make sure the configured runtime has
# a synchronous `init` function that takes the
# configured arguments.
config :livebook, :default_runtime, {Livebook.Runtime.Embedded, []}

config :livebook, router_helpers_module: Bonfire.Web.Router.Helpers
