# SPDX-FileCopyrightText: 2023 Bonfire contributors <https://github.com/bonfire-networks/bonfire-app/graphs/contributors>
#
# SPDX-License-Identifier: AGPL-3.0-only

import Config

alias Bonfire.Federate.ActivityPub.Adapter

actor_types = ["Person", "Group", "Application", "Service", "Organization"]

config :bonfire,
  # enable/disable logging of federation logic
  log_federation: true,
  federation_fallback_module: Bonfire.Social.APActivities

config :bonfire, actor_AP_types: actor_types

# config :bonfire, Bonfire.Instance,
# hostname: hostname,
# description: desc
