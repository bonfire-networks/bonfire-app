# SPDX-FileCopyrightText: 2023 Bonfire contributors <https://github.com/bonfire-networks/bonfire-app/graphs/contributors>
#
# SPDX-License-Identifier: AGPL-3.0-only

import Config

config :bonfire_mailer,
  check_mx: true,
  check_format: true

config :bonfire_mailer, Bonfire.Mailer,
  # what service you want to use to send emails, from these: https://github.com/thoughtbot/bamboo#available-adapters
  # we recommend leaving LocalAdapter (which is just a fallback which won't actually send emails) and setting the actual adapter in runtime.exs
  adapter: Bamboo.LocalAdapter
