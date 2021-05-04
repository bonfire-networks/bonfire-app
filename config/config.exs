import Config

flavour =
  System.get_env("BONFIRE_FLAVOUR", "flavours/classic")
  |> Path.expand()

import_config "#{flavour}/config/config.exs"
