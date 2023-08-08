# SPDX-FileCopyrightText: 2023 Bonfire contributors <https://github.com/bonfire-networks/bonfire-app/graphs/contributors>
#
# SPDX-License-Identifier: AGPL-3.0-only

import Config

config :bonfire_quantify,
  templates_path: "lib"

# specify what types a unit can have as context
config :bonfire_quantify, Bonfire.Quantify.Units, valid_contexts: [:any]
# Bonfire.Quantify.Units, Bonfire.Data.Identity.User
