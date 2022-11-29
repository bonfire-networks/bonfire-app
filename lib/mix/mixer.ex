if not Code.ensure_loaded?(Bonfire.Mixer) do
  defmodule Bonfire.Mixer do
    def deps(config, deps_subtype, extensions \\ [])

    def deps(config, :bonfire, extensions) do
      extensions = umbrella_extension_names()
      prefixes = multirepo_prefixes(config)

      (config[:deps] || config)
      |> Enum.filter(&in_multirepo?(&1, prefixes, extensions))
    end

    def deps(config, :update = deps_subtype, extensions) do
      # extensions = extensions #|| umbrella_extension_names()
      prefixes = multirepo_prefixes(config)

      (config[:deps] || config)
      |> Enum.filter(
        &(include_dep?(deps_subtype, &1, config[:deps_prefixes][deps_subtype]) ||
            in_multirepo?(&1, prefixes, extensions))
      )
    end

    def deps(config, deps_subtype, _) when is_atom(deps_subtype),
      do:
        (config[:deps] || config)
        # |> IO.inspect(limit: :infinity)
        |> Enum.filter(&include_dep?(deps_subtype, &1, config[:deps_prefixes][deps_subtype]))

    def deps_names_for(type, deps \\ mix_config()) do
      deps(deps, type)
      |> Enum.map(&dep_name/1)
    end

    def deps_names(deps \\ deps()) do
      deps
      |> Enum.map(&dep_name/1)
      |> Enum.join(" ")
    end

    def deps do
      if function_exported?(Mix.Project, :config, 0),
        do: Mix.Project.config()[:deps],
        else: Bonfire.Application.deps()
    end

    def umbrella_extensions do
      # || Mix.Dep.Umbrella.loaded()
      Mix.Project.apps_paths() ||
        Mess.deps([path: "config/deps.path"], [], umbrella_only: true) ||
        []
    end

    def umbrella_extension_names do
      umbrella_extensions()
      |> Enum.map(fn
        %{app: name} -> name
        {name, _path} -> name
      end)
    end

    def umbrella_extension_paths do
      umbrella_extensions()
      |> Enum.map(fn
        {name, path} when is_binary(path) -> {name, path: path}
        dep -> dep
      end)
    end

    def mix_config do
      if function_exported?(Mix.Project, :config, 0),
        do: Mix.Project.config(),
        else: Bonfire.Application.config()
    end

    def multirepo_prefixes(config \\ mix_config()),
      do:
        List.wrap(config[:deps_prefixes] || mix_config()[:deps_prefixes])
        |> Enum.flat_map(fn {_, list} -> list || [] end)
        |> Enum.uniq()

    def in_multirepo?(dep, deps_prefixes \\ multirepo_prefixes(), extensions \\ nil),
      do:
        include_dep?(:bonfire, dep, deps_prefixes) ||
          elem(dep, 0) in (extensions || umbrella_extension_names())

    def deps_recompile(deps \\ deps_names(:bonfire)),
      do: Mix.Task.run("bonfire.dep.compile", ["--force"] ++ List.wrap(deps))

    # def flavour_path(path) when is_binary(path), do: path
    def flavour_path(config),
      do: System.get_env("FLAVOUR_PATH", "flavours/" <> flavour(config))

    def flavour(config \\ mix_config())

    def flavour(default_flavour) when is_binary(default_flavour),
      do: System.get_env("FLAVOUR") || default_flavour

    def flavour(config), do: System.get_env("FLAVOUR") || config[:default_flavour]

    def config_path(config_or_flavour, filename),
      do: Path.expand(Path.join([flavour_path(config_or_flavour), "config", filename]))

    def forks_path(), do: System.get_env("FORKS_PATH", "extensions/")

    def mess_sources(config_or_flavour) do
      do_mess_sources(System.get_env("WITH_FORKS", "1"))
      |> Enum.map(fn {k, v} -> {k, config_path(config_or_flavour, v)} end)
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

    def beam_paths(deps \\ mix_config(), type \\ :bonfire, extras \\ []) do
      build = Mix.Project.build_path()

      (extras ++ deps_names_for(type, deps))
      # |> IO.inspect
      |> Enum.map(&beam_path(&1, build))
    end

    defp beam_path(app, build),
      do: Path.join([build, "lib", dep_name(app), "ebin"])

    def docs_beam_paths(config \\ mix_config()) do
      beam_paths(config, :docs, umbrella_extension_names() || [])
    end

    def readme_paths(config),
      do:
        List.wrap(config[:guides]) ++
          Enum.map(Path.wildcard("flavours/*/README.md"), &flavour_readme/1) ++
          Enum.map(Path.wildcard("docs/DEPENDENCIES/*.md"), &flavour_deps_doc/1) ++
          Enum.flat_map(
            deps_names_for(:docs, config) ++ umbrella_extension_paths(),
            &readme_path/1
          )

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
    def doc_dep_urls(config), do: deps(config, :docs) |> Enum.map(&doc_dep_url/1)
    defp doc_dep_url(dep), do: {elem(dep, 0), "./"}

    def source_url_pattern("deps/" <> _ = path, line),
      do: bonfire_ext_pattern(path, line)

    def source_url_pattern("extensions/" <> _ = path, line),
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
    def include_dep?(type, dep, config_or_prefixes) do
      # IO.inspect(config_or_prefixes)
      String.starts_with?(
        dep_name(dep),
        config_or_prefixes[:deps_prefixes][type] || config_or_prefixes[type] || "bonfire"
        # || mix_config()[:deps_prefixes][type]
      )
    end

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
      Mix.compilers()
    end

    def catalogues(_env) do
      [
        "deps/surface/priv/catalogue",
        dep_path("bonfire_ui_social") <> "/priv/catalogue"
      ]
    end
  end
end
