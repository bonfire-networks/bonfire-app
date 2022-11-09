if not Code.ensure_loaded?(Bonfire.Mixer) do
  defmodule Bonfire.Mixer do

    def deps(config, deps_subtype)

    def deps(config, :bonfire) do
      prefixes = multirepo_prefixes(config)
      Enum.filter(config[:deps] || config, &in_multirepo?(&1, prefixes))
    end

    def deps(config, :update = deps_subtype) do
      prefixes = multirepo_prefixes(config)
      Enum.filter(
          config[:deps] || config,
          &( include_dep?(deps_subtype, &1, config[:deps_prefixes][deps_subtype]) || in_multirepo?(&1, prefixes) )
        )
      |> IO.inspect(limit: :infinity)
    end

    def deps(config, deps_subtype) when is_atom(deps_subtype),
      do:
        Enum.filter(
          config[:deps] || config,
          &include_dep?(deps_subtype, &1, config[:deps_prefixes][deps_subtype])
        )

    def deps_for(type, deps \\ Bonfire.Application.deps()) do
      deps(deps, type)
      |> Enum.map(&dep_name/1)
    end

    def multirepo_prefixes(config \\ Bonfire.Application.mix_config()),
      do:
        Enum.flat_map(config[:deps_prefixes], fn {_, list} -> list end)
        |> Enum.uniq()

    def in_multirepo?(dep, deps_prefixes \\ multirepo_prefixes()),
      do: include_dep?(:bonfire, dep, deps_prefixes)

    def deps_recompile(deps \\ deps_for(:bonfire)),
      do: Mix.Task.run("bonfire.dep.compile", ["--force"] ++ List.wrap(deps))

    # def flavour_path(path) when is_binary(path), do: path
    def flavour_path(config),
      do: System.get_env("FLAVOUR_PATH", "flavours/" <> flavour(config))

    def flavour(config \\ Bonfire.Application.mix_config()),
      do: System.get_env("FLAVOUR") || config[:default_flavour]

    def config_path(config, filename),
      do: Path.expand(Path.join([flavour_path(config), "config", filename]))

    def forks_path(), do: System.get_env("FORKS_PATH", "forks/")

    def mess_sources(config) do
      do_mess_sources(System.get_env("WITH_FORKS", "1"))
      |> Enum.map(fn {k, v} -> {k, config_path(config, v)} end)
    end

    defp do_mess_sources("0"), do: [git: "deps.git", hex: "deps.hex"]

    defp do_mess_sources(_),
      do: [path: "deps.path", git: "deps.git", hex: "deps.hex"]

    def deps_to_clean(deps, type) do
      deps(deps, type)
      |> deps_names()
    end

    def deps_to_update(config) do
      deps(config, :update)
      |> deps_names()
      |> IO.inspect(
        label:
          "Running Bonfire #{version(config)} with configuration from #{flavour_path(config)} in #{Mix.env()} environment. You can run `just mix bonfire.deps.update` to update these extensions and dependencies"
      )
    end

    # Specifies which paths to include in docs

    def beam_paths(deps, type \\ :all) do
      build = Mix.Project.build_path()

      ([:bonfire] ++ deps(deps, type))
      |> Enum.map(&beam_path(&1, build))
    end

    defp beam_path(app, build),
      do: Path.join([build, "lib", dep_name(app), "ebin"])

    def readme_paths(config),
      do:
        List.wrap(config[:guides]) ++
          Enum.map(Path.wildcard("flavours/*/README.md"), &flavour_readme/1) ++
          Enum.map(Path.wildcard("docs/DEPENDENCIES/*.md"), &flavour_deps_doc/1) ++
          Enum.flat_map(deps(config, :docs), &readme_path/1)

    defp readme_path(dep) when not is_nil(dep),
      do: dep_paths(dep, "README.md") |> List.first() |> readme_path(dep)

    defp readme_path(path, dep) when not is_nil(path),
      do: [{path |> String.to_atom(), [filename: "extension-" <> dep_name(dep)]}]

    defp readme_path(_, _), do: []

    def flavour_readme(path),
      do: {path |> String.to_atom(), [filename: path |> String.split("/") |> Enum.at(1)]}

    def flavour_deps_doc(path),
      do:
        {path |> String.to_atom(),
         [
           title:
             path
             |> String.split("/")
             |> Enum.at(2)
             |> String.slice(0..-4)
             |> String.capitalize(),
           filename:
             path
             |> String.split("/")
             |> Enum.at(2)
             |> String.slice(0..-4)
             |> then(&"deps-#{&1}")
         ]}

    # [plug: "https://myserver/plug/"]
    def doc_deps(config), do: deps(config, :docs) |> Enum.map(&doc_dep/1)
    defp doc_dep(dep), do: {elem(dep, 0), "./"}

    def source_url_pattern("deps/" <> _ = path, line),
      do: bonfire_ext_pattern(path, line)

    def source_url_pattern("forks/" <> _ = path, line),
      do: bonfire_ext_pattern(path, line)

    def source_url_pattern(path, line), do: bonfire_app_pattern(path, line)

    def bonfire_ext_pattern(path, line),
      do:
        bonfire_ext_pattern(
          path |> String.split("/") |> Enum.at(1),
          path |> String.split("/") |> Enum.slice(2..1000) |> Enum.join("/"),
          line
        )

    def bonfire_ext_pattern(dep, path, line),
      do:
        bonfire_app_pattern(
          "https://github.com/bonfire-networks/#{dep}/blob/main/%{path}#L%{line}",
          path,
          line
        )

    def bonfire_app_pattern(path, line),
      do:
        bonfire_app_pattern(
          "https://github.com/bonfire-networks/bonfire-app/blob/main/%{path}#L%{line}",
          path,
          line
        )

    def bonfire_app_pattern(pattern, path, line),
      do:
        pattern
        |> String.replace("%{path}", "#{path}")
        |> String.replace("%{line}", "#{line}")

    # Specifies which paths to include when running tests
    def test_paths(config),
      do: ["test" | Enum.flat_map(deps(config, :test), &dep_paths(&1, "test"))]

    # Specifies which paths to compile per environment
    def elixirc_paths(config, :test),
      do: [
        "lib",
        "test/support"
        | Enum.flat_map(deps(config, :test), &dep_paths(&1, "test/support"))
      ]

    def elixirc_paths(_, env), do: ["lib"] ++ catalogues(env)

    def include_dep?(type, dep, config_or_prefixes)

    def include_dep?(:update, dep, _config_or_prefixes) when is_tuple(dep),
      do: unpinned_git_dep?(dep)

    # defp include_dep?(:docs = type, dep, deps_prefixes), do: String.starts_with?(dep_name(dep), deps_prefixes || @config[:deps_prefixes][type]) || git_dep?(dep)
    def include_dep?(type, dep, config_or_prefixes),
      do:
        String.starts_with?(
          dep_name(dep),
          (config_or_prefixes[:deps_prefixes][type]) || (config_or_prefixes)
        )

    # defp git_dep?(dep) do
    #   spec = elem(dep, 1)
    #   is_list(spec) && spec[:git]
    # end

    def unpinned_git_dep?(dep) do
      spec = elem(dep, 1)
      is_list(spec) && spec[:git] && !spec[:commit]
    end

    def dep_name(dep) when is_tuple(dep), do: elem(dep, 0) |> dep_name()
    def dep_name(dep) when is_atom(dep), do: Atom.to_string(dep)
    def dep_name(dep) when is_binary(dep), do: dep

    def deps_names(deps) do
      deps
      |> Enum.map(&dep_name/1)
      |> Enum.join(" ")
    end

    def dep_path(dep) when is_binary(dep) do
      path_if_exists(forks_path() <> dep) ||
        path_if_exists(
          (Mix.Project.deps_path() <> "/" <> dep)
          |> Path.expand(File.cwd!())
        ) ||
        "."
    end

    def dep_path(dep) do
      spec = elem(dep, 1)

      path =
        if is_list(spec) && spec[:path],
          do: spec[:path],
          else:
            (Mix.Project.deps_path() <> "/" <> dep_name(dep))
            |> Path.relative_to_cwd()

      path_if_exists(path)
    end

    defp path_if_exists(path), do: if(File.exists?(path), do: path)

    def dep_paths(dep, extra) when is_list(extra),
      do: Enum.flat_map(extra, &dep_paths(dep, &1))

    def dep_paths(dep, extra) when is_binary(extra) do
      dep_path = dep_path(dep)

      if dep_path do
        path = Path.join(dep_path, extra) |> path_if_exists()
        if path, do: [path], else: []
      else
        []
      end
    end

    def version(config) do
      config[:version]
      |> String.split("-", parts: 2)
      |> List.insert_at(1, flavour(config))
      |> Enum.join("-")
    end

    # def compilers(:dev) do
    #   [:unused] ++ compilers(nil)
    # end

    def compilers(_) do
      [:phoenix] ++ Mix.compilers()
    end

    def catalogues(_env) do
      [
        "deps/surface/priv/catalogue",
        dep_path("bonfire_ui_social") <> "/priv/catalogue"
      ]
    end
  end
end
