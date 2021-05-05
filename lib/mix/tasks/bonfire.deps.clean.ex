defmodule Mix.Tasks.Bonfire.Deps.Clean do

  use Mix.Task

  def run(_args) do
    deps = 
      Mix.Project.get!().project()[:deps]
      |> Enum.map(&dep_name/1)
      |> Enum.filter(&data_dep?/1)
    Mix.Tasks.Deps.Clean.run(deps ++ ["--build"])
  end

  def data_dep?(dep), do: String.starts_with?(dep, "bonfire_data_")
        
  defp dep_name(dep), do: Atom.to_string(elem(dep, 0))

end
