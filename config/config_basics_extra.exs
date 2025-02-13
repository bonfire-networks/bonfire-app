import Config

cond do
  File.exists?("../extensions/bonfire/config/config.exs") ->
    import_config "../extensions/bonfire/config/config.exs"

  File.exists?("../deps/bonfire/config/config.exs") ->
    import_config "../deps/bonfire/config/config.exs"

  true ->
    import_config "config_basics.exs"
end
