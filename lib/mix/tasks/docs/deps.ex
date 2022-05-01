defmodule Mix.Tasks.Docs.Deps do
  use Mix.Task

  @shortdoc "Generates docs for your app and its all deps"
  @recursive true

  @moduledoc """
  Prints the dependency tree.
      mix docs.deps
  If no dependency is given, it uses the tree defined in the `mix.exs` file.
  ## Command line options
    * `--only` - the environment to include dependencies for
    * `--target` - the target to include dependencies for
    * `--exclude` - exclude dependencies which you do not want to see in docs.
    * any arguments supported by `mix docs` will be passed along
  """
  @switches [only: :string, target: :string, exclude: :keep]

  @impl true
  def run(args) do
    Mix.Project.get!()
    {opts, args, _} = OptionParser.parse(args, switches: @switches)

    deps_opts =
      for {switch, key} <- [only: :env, target: :target],
          value = opts[switch],
          do: {key, :"#{value}"}

    excluded = Keyword.get_values(opts, :exclude)

    deps = Mix.Dep.load_on_environment(deps_opts)
    |> prepare_list(opts)
    |> List.flatten()
    |> Enum.reject(& Atom.to_string(dep_name(&1)) in excluded)
    |> Enum.uniq_by(&dep_name(&1))

    config = Mix.Project.config()
    build_path = Mix.Project.build_path()

    docs_config = Keyword.get(config, :docs, [])

    docs_config = docs_config
    |> Keyword.put(:deps, Enum.map(deps, & {dep_name(&1), "./"}))
    |> Keyword.put(:source_beam, Enum.map(deps, &Path.join([build_path, "lib", Atom.to_string(dep_name(&1)), "ebin"])))
    |> Keyword.put(:extras, Keyword.get(docs_config, :extras, []) ++ Enum.flat_map(deps, &readme_path/1))

    Mix.Tasks.Docs.run(args, Keyword.put(config, :docs, docs_config))
  end

  defp prepare_list(deps, opts) when is_list(deps) do
    Enum.flat_map(deps, fn
      %Mix.Dep{deps: nested_deps} = dep ->
        [dep] ++ prepare_list(nested_deps, opts)

      dep ->
        dep
    end)
  end

  defp readme_path(dep) when not is_nil(dep), do: dep_paths(dep, "README.md") |> List.first |> readme_path(dep)
  defp readme_path(path, dep) when not is_nil(path), do: [{path |> String.to_atom, [filename: "extension-#{dep_name(dep)}"]}]
  defp readme_path(_, _), do: []

  defp dep_path(dep) do

    path = if is_list(dep) && dep[:path],
      do: dep[:path],
      else: Mix.Project.deps_path() <> "/#{dep_name(dep)}" |> Path.relative_to(File.cwd!)

    path_if_exists(path)
  end

  defp dep_paths(dep, extra) when is_list(extra), do: Enum.flat_map(extra, &dep_paths(dep, &1))
  defp dep_paths(dep, extra) when is_binary(extra) do
    dep_path = dep_path(dep)
    if dep_path do
      path = Path.join(dep_path, extra) |> path_if_exists()
      if path, do: [path], else: []
    else
      []
    end
  end

  defp dep_name(%Mix.Dep{app: dep}) when is_atom(dep), do: dep
  defp dep_name(dep) when is_tuple(dep), do: elem(dep, 0) |> dep_name()
  defp dep_name(dep) when is_atom(dep), do: dep
  defp dep_name(dep) when is_binary(dep), do: dep

  defp path_if_exists(path), do: if File.exists?(path), do: path

end
