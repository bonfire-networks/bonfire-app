import Config

config_file = "config/bonfire_data.exs"

cond do
  File.exists?("extensions/bonfire/#{config_file}") ->
    System.get_env("MIX_QUIET") ||
      IO.puts("Load #{config_file} from local clone of `bonfire` dep")

    import_config "../extensions/bonfire/#{config_file}"

  File.exists?("deps/bonfire/#{config_file}") ->
    System.get_env("MIX_QUIET") || IO.puts("Load #{config_file} from `bonfire` dep")
    import_config "../deps/bonfire/#{config_file}"

  true ->
    System.get_env("MIX_QUIET") || IO.puts("No #{config_file} found")
    nil
end
