# SPDX-FileCopyrightText: 2023 Bonfire contributors <https://github.com/bonfire-networks/bonfire-app/graphs/contributors>
#
# SPDX-License-Identifier: AGPL-3.0-only

import Config

config :bonfire_open_id,
  templates_path: "lib"

config :boruta, Boruta.Oauth,
  repo: Bonfire.Common.Repo,
  contexts: [
    resource_owners: Bonfire.OpenID.Integration
  ]

if Mix.env() == :test do
  config :bonfire_open_id, :oauth_module, Boruta.OauthMock
  config :bonfire_open_id, :openid_module, Boruta.OpenidMock
end
