import Config

config_file = "config/bonfire_data.exs"

cond do
  File.exists?("extensions/bonfire/#{config_file}") ->
    IO.puts("Load #{config_file} from local clone of bonfire_spark")
    import_config "../extensions/bonfire/#{config_file}"

  File.exists?("deps/bonfire/#{config_file}") ->
    IO.puts("Load #{config_file} from bonfire_spark dep")
    import_config "../deps/bonfire/#{config_file}"

  true ->
    IO.puts("No #{config_file} found")
    nil
end
