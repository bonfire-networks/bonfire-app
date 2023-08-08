# SPDX-FileCopyrightText: 2023 Bonfire contributors <https://github.com/bonfire-networks/bonfire-app/graphs/contributors>
#
# SPDX-License-Identifier: AGPL-3.0-only

import Config

config :bonfire_geolocate,
  templates_path: "lib"

config :bonfire, :js_config, mapbox_api_key: System.get_env("MAPBOX_API_KEY")
