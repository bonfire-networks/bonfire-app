defmodule Mix.Tasks.Bonfire.Deps.Update do

  use Mix.Task

  @update_deps [
    :activity_pub,
    :query_elf,
    :bonfire_mailer,
    :bonfire_fail,
    :bonfire_search,
    :bonfire_recyclapp,
    :bonfire_api_graphql,
  ]

  def run(_args) do
    Mix.Project.get!().project()[:deps]
    |> Enum.filter(&ok?/1)
    |> Enum.map(&elem(&1, 0))
    |> Enum.map(&Atom.to_string/1)
    |> Mix.Tasks.Deps.Update.run()
  end

  defp ok?(dep), do: elem(dep, 0) in @update_deps or unpinned_git_dep?(dep)

  def unpinned_git_dep?(dep) do
    spec = elem(dep, 1)
    is_list(spec) && spec[:git] && !spec[:commit]
  end

end
