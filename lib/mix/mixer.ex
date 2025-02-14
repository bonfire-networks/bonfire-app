if not Code.ensure_loaded?(Bonfire.Mixer) do
  defmodule Bonfire.Mixer do
    def deps_for(type, config \\ mix_config()) do
      deps(config, type)
    end

    def deps(config, deps_subtype, extensions \\ [])

    def deps(config, :bonfire, extensions) do
      # extensions = extensions || umbrella_extension_names()
      # |> log(label: "prefixes")
      prefixes =
        case multirepo_prefixes(config) do
          [] ->
            IO.puts(
              "No prefixes found in config, fallback to including any deps that starts with 'bonfire'..."
            )

            ["bonfire"]

          prefixes ->
            prefixes
        end

      (config[:deps] || config)
      # |> log()
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
        # |> log(limit: :infinity)
        |> Enum.filter(&include_dep?(deps_subtype, &1, config[:deps_prefixes][deps_subtype]))

    def deps do
      if function_exported?(Mix.Project, :config, 0),
        do: Mix.Project.config()[:deps],
        else: Bonfire.Application.config()[:deps]
    end

    def deps_names_for(type, config \\ mix_config()) do
      deps(config, type)
      |> Enum.map(&dep_name/1)
    end

    def deps_names_list(deps \\ deps(), as_atom \\ true) do
      deps
      |> Enum.map(&dep_name(&1, as_atom))
    end

    def deps_names(deps \\ deps()) do
      deps_names_list(deps, false)
      |> Enum.join(" ")
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
      cond do
        function_exported?(Bonfire.Umbrella.MixProject, :config, 0) ->
          Bonfire.Umbrella.MixProject.config()

        Code.ensure_loaded?(Bonfire.Application) ->
          Bonfire.Application.config()

        Code.ensure_loaded?(Mix.Project) ->
          Mix.Project.config()

        true ->
          IO.warn("Could not get config")
          []
      end
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

    def flavour(config \\ mix_config())

    def flavour(default_flavour) when is_binary(default_flavour),
      do: System.get_env("FLAVOUR") || default_flavour

    def flavour(config), do: System.get_env("FLAVOUR") || config[:default_flavour]

    def config_path(path \\ nil, filename),
      do: Path.expand(Path.join([path || "config", filename]))

    def forks_path(), do: System.get_env("FORKS_PATH", "extensions/")
    def forks_paths(), do: [forks_path(), "forks/"]

    def compile_disabled? do
      case System.get_env("COMPILE_DISABLED_EXTENSIONS", "prod") do
        "prod" -> System.get_env("MIX_ENV") == "prod"
        "1" -> true
        "yes" -> true
        "all" -> true
        _ -> false
      end
    end

    def mess_sources(flavour) do
      mess_source_files(System.get_env("WITH_FORKS", "1"), System.get_env("WITH_GIT_DEPS", "1"))
      |> maybe_all_flavour_sources(flavour, System.get_env("WITH_ALL_FLAVOUR_DEPS", "1"))

      # |> log(label: "messy")
    end

    # def mess_other_flavour_deps(current_flavour \\ System.get_env("FLAVOUR", "ember")) do
    #   current_flavour_sources =
    #     mess_source_files(System.get_env("WITH_FORKS", "1"), System.get_env("WITH_GIT_DEPS", "1"))

    #   current_flavour_deps =
    #     enum_mess_sources(current_flavour_sources)
    #     # |> log(label: "current_mess_sources")
    #     |> Mess.deps([], [])
    #     |> deps_names_list()

    #   # |> log(label: "current_flavour_deps", limit: :infinity)

    #   other_flavours_sources = other_flavour_sources(current_flavour_sources, current_flavour)
    #   # |> log(label: "other_flavours_sources")

    #   Mess.deps(other_flavours_sources, [], [])
    #   # |> log(label: "other_flavours_deps")
    #   |> Enum.reject(fn
    #     {dep, _} -> dep in current_flavour_deps
    #     {dep, _, _} -> dep in current_flavour_deps
    #   end)
    #   |> log("other_flavour_deps")
    # end

    # def mess_other_flavour_dep_names(current_flavour \\ System.get_env("FLAVOUR", "ember")) do
    #   mess_other_flavour_deps(current_flavour)
    #   |> deps_names_list()
    # end

    defp maybe_all_flavour_sources(
           existing_sources,
           current_flavour,
           "1" = _WITH_ALL_FLAVOUR_DEPS
         ) do
      # ++ [disabled: other_flavour_sources(existing_sources, current_flavour)]
      enum_mess_sources(existing_sources)

      # |> log("all_flavour_sources")
    end

    defp maybe_all_flavour_sources(existing_sources, _flavour, _not_WITH_ALL_FLAVOUR_DEPS) do
      enum_mess_sources(existing_sources)
    end

    # def other_flavour_sources(
    #       existing_sources \\ mess_source_files(
    #         System.get_env("WITH_FORKS", "1"),
    #         System.get_env("WITH_GIT_DEPS", "1")
    #       ),
    #       current_flavour \\ System.get_env("FLAVOUR", "ember")
    #     ) do
    #   flavour_paths =
    #     for path <- "flavours/*/config/" |> Path.wildcard() do
    #       path
    #     end
    #     |> Enum.reject(&(&1 == "flavours/#{current_flavour}/config"))

    #   # |> log(label: "creams")

    #   Enum.map(
    #     flavour_paths,
    #     &(List.first(existing_sources)
    #       |> enum_mess_sources(&1))
    #   )
    # end

    defp enum_mess_sources(sublist, path \\ nil)

    defp enum_mess_sources(sublist, path) when is_list(sublist) do
      sublist
      |> Enum.map(&enum_mess_sources(&1, path))
    end

    defp enum_mess_sources({k, v}, path) do
      {k, config_path(path, v)}
    end

    defp mess_source_files("0" = _not_WITH_FORKS, "0" = _not_WITH_GIT_DEPS),
      do: [[hex: "current_flavour/deps.hex"], [hex: "deps.hex"]]

    defp mess_source_files("0" = _not_WITH_FORKS, "1" = _WITH_GIT_DEPS),
      do: [
        [git: "current_flavour/deps.git", hex: "current_flavour/deps.hex"],
        [git: "deps.git", hex: "deps.hex"]
      ]

    defp mess_source_files("1" = _WITH_FORKS, "0" = _not_WITH_GIT_DEPS),
      do: [
        [path: "current_flavour/deps.path", hex: "current_flavour/deps.hex"],
        [path: "deps.path", hex: "deps.hex"]
      ]

    defp mess_source_files("1" = _WITH_FORKS, "1" = _WITH_GIT_DEPS),
      do: [
        [
          path: "current_flavour/deps.path",
          git: "current_flavour/deps.git",
          hex: "current_flavour/deps.hex"
        ],
        [path: "deps.path", git: "deps.git", hex: "deps.hex"]
      ]

    def deps_to_clean(config, type) do
      deps(config, type)
      |> deps_names()
      |> or_unused()
    end

    defp or_unused(""), do: " --unused"
    defp or_unused(deps), do: deps

    def deps_to_update(config) do
      deps(config, :update)
      |> deps_names()

      # |> log(
      #   "Running Bonfire #{version(config)} at #{System.get_env("HOSTNAME", "localhost")} in #{Mix.env()} environment. You can run `just mix bonfire.deps.update` to update these extensions and dependencies"
      # )
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

    def extra_guide_paths(config) do
      deps = deps_names_for(:docs, config) ++ umbrella_extension_paths()

      # Enum.map(Path.wildcard("flavours/*/README.md"), &flavour_readme/1) ++
      List.wrap(config[:guides]) ++
        Enum.map(Path.wildcard("docs/DEPENDENCIES/*.md"), &flavour_deps_doc/1) ++
        Enum.flat_map(
          deps,
          &readme_path/1
        ) ++
        Enum.flat_map(
          deps,
          &dep_paths(&1, "docs/*.md")
        )

      # |> IO.inspect(limit: :infinity)
    end

    defp readme_path(dep) when not is_nil(dep),
      do: dep_paths(dep, "README.md") |> List.first() |> readme_path(dep)

    defp readme_path(path, dep) when not is_nil(path),
      # naming the readme's like this should mean they get overriden by the moduledoc of the extension's main module, which ideally read the readme contents using e.g. `@moduledoc "./README.md" |> File.stream!() |> Enum.drop(1) |> Enum.join()`
      do: [
        {path
         |> Path.relative_to_cwd()
         |> String.to_atom(),
         [
           filename:
             dep_name(dep)
             |> String.replace("bonfire_data_", "Bonfire/Data/")
             |> String.replace("bonfire_api_", "Bonfire/API/")
             |> String.replace("bonfire_ui_", "Bonfire/UI/")
             |> String.replace("bonfire_editor_", "Bonfire/Editor/")
             |> String.replace("bonfire_", "bonfire/")
             |> String.replace("needle_", "Needle/")
             |> Macro.camelize()
         ]}
        # |> log()
      ]

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
             |> String.slice(0..-4//1)
             |> String.capitalize(),
           filename:
             path
             |> String.split("/")
             |> Enum.at(2)
             |> String.slice(0..-4//1)
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
    def test_paths(config) do
      testable_paths =
        test_deps(config)
        |> Enum.flat_map(&dep_paths(&1, "test"))

      # |> IO.inspect(label: "testable_paths")

      [
        "test"
        | testable_paths
      ]
    end

    def test_deps(config) do
      case System.get_env("MIX_TEST_ONLY") do
        "backend" ->
          Enum.reject(deps(config, :test_backend) ++ umbrella_extension_paths(), fn dep ->
            String.starts_with?(dep_name(dep), ["bonfire_ui_", "bonfire_federate_"])
          end)

        "federation" ->
          deps(config, :test_federation) ++ umbrella_extension_paths()

        "ui" ->
          deps(config, :test_ui) ++ umbrella_extension_paths()

        _all ->
          deps(config, :test) ++ umbrella_extension_paths()
      end
      |> Enum.uniq()
      |> Enum.reject(fn
        {_dep, opts} -> opts[:runtime] == false
        {_dep, _v, opts} -> opts[:runtime] == false
      end)

      # |> log("test_deps: #{System.get_env("MIX_TEST_ONLY")}")
    end

    # Specifies which paths to compile per environment
    def elixirc_paths(config, :test) do
      paths_to_test = cli_args_paths_to_test()

      testable_deps =
        test_deps(config)
        |> Enum.flat_map(&dep_paths/1)

      testable_paths =
        case find_matching_paths(paths_to_test, testable_deps) do
          [] -> testable_deps
          testable_paths -> testable_paths
        end

      [
        "lib",
        "test/support"
        | dep_paths(testable_paths, "test/support")
        # |> IO.inspect(label: "elixirc_paths")
      ]
    end

    def elixirc_paths(_, env),
      do:
        [
          "lib"
        ] ++ catalogues(env)

    def catalogues(_env) do
      [
        "deps/surface/priv/catalogue",
        dep_path("bonfire_ui_common") <> "/priv/catalogue"
      ]
    end

    def cli_args_paths_to_test do
      # NOTE: must be kept up to date with @switches in https://github.com/elixir-lang/elixir/blob/main/lib/mix/lib/mix/tasks/test.ex
      switches = [
        all_warnings: :boolean,
        breakpoints: :boolean,
        force: :boolean,
        color: :boolean,
        cover: :boolean,
        export_coverage: :string,
        trace: :boolean,
        max_cases: :integer,
        max_failures: :integer,
        include: :keep,
        exclude: :keep,
        seed: :integer,
        only: :keep,
        compile: :boolean,
        start: :boolean,
        timeout: :integer,
        raise: :boolean,
        deps_check: :boolean,
        archives_check: :boolean,
        elixir_version_check: :boolean,
        failed: :boolean,
        stale: :boolean,
        listen_on_stdin: :boolean,
        formatter: :keep,
        slowest: :integer,
        slowest_modules: :integer,
        partitions: :integer,
        preload_modules: :boolean,
        warnings_as_errors: :boolean,
        profile_require: :string,
        exit_status: :integer,
        repeat_until_failure: :integer
      ]

      {_opts, wildcards_to_test, _} = System.argv() |> OptionParser.parse(strict: switches)

      wildcards_to_test
      |> Enum.map(&(&1 |> Path.expand() |> Path.wildcard() |> Path.relative_to_cwd()))

      # |> IO.inspect(label: "paths_to_test")
    end

    def find_matching_paths(paths_to_test, testable_deps) do
      testable_deps_set = MapSet.new(testable_deps)

      Enum.flat_map(paths_to_test, fn filter_path ->
        Enum.filter(testable_deps_set, fn dep_path ->
          filter_path == dep_path or String.starts_with?(filter_path, dep_path) or
            String.starts_with?(dep_path, filter_path)
        end)
      end)
      |> Enum.uniq()
      |> Enum.reject(&is_nil/1)
    end

    def include_dep?(:update, dep, prefixes) when is_tuple(dep),
      do:
        unpinned_git_dep?(dep) ||
          String.starts_with?(
            dep_name(dep),
            prefixes
          )

    # defp include_dep?(:docs = type, dep, deps_prefixes), do: String.starts_with?(dep_name(dep), deps_prefixes || @config[:deps_prefixes][type]) || git_dep?(dep)
    def include_dep?(_type, dep, prefixes) do
      String.starts_with?(
        dep_name(dep),
        prefixes
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

    def dep_name(dep, as_atom \\ false)
    def dep_name(dep, as_atom) when is_tuple(dep), do: elem(dep, 0) |> dep_name(as_atom)
    def dep_name(dep, false) when is_atom(dep), do: Atom.to_string(dep)
    def dep_name(dep, true) when is_binary(dep), do: String.to_existing_atom(dep)
    def dep_name(dep, _), do: dep

    def dep_path(dep, force? \\ false)

    def dep_path(dep, force?) when is_binary(dep) or is_atom(dep) do
      Enum.map(forks_paths() ++ [""], &path_if_exists("#{&1}#{dep}"))
      |> Enum.reject(&is_nil/1)
      |> List.first() ||
        (
          path =
            (Mix.Project.deps_path() <> "/#{dep}")
            |> Path.expand(File.cwd!())

          if force?, do: path, else: path_if_exists(path) || "."
        )
    end

    def dep_path(dep, force?) when is_tuple(dep) do
      spec = elem(dep, 1)

      path =
        if is_list(spec) && spec[:path],
          do: spec[:path],
          else:
            (Mix.Project.deps_path() <> "/" <> dep_name(dep))
            |> Path.relative_to_cwd()

      if force?, do: path, else: path_if_exists(path)
    end

    defp path_if_exists(path), do: if(File.exists?(path), do: path)

    def dep_paths(deps, extra \\ "/")

    def dep_paths(deps, extra) when is_list(deps),
      do: Enum.flat_map(deps, &dep_paths(&1, extra))

    def dep_paths(dep, extra) when is_list(extra),
      do: Enum.flat_map(extra, &dep_paths(dep, &1))

    def dep_paths(dep, extra) when is_binary(extra) do
      dep_path =
        dep_path(dep, true)
        |> IO.inspect()

      if dep_path do
        # path = 
        Path.join(dep_path, extra)
        |> IO.inspect()
        |> Path.wildcard()

        # if path, do: [path], else: []
      else
        []
      end
    end

    def version(config) do
      config[:version]
      |> String.split("-", parts: 2)
      |> List.insert_at(1, flavour(config) |> String.replace("_", "-"))
      |> Enum.join("-")
    end

    # def compilers(:dev) do
    #   [:unused] ++ compilers(nil)
    # end

    def compilers(_) do
      Mix.compilers() ++ [:surface]
    end

    def deps_tree do
      if function_exported?(Mix.Project, :deps_tree, 0) do
        Mix.Project.deps_tree()
      end
    end

    def deps_tree_flat(tree \\ deps_tree())

    def deps_tree_flat(tree) when is_map(tree) do
      # note that you should call the compile-time cached list in Bonfire.Application
      (Map.values(tree) ++ Map.keys(tree))
      |> List.flatten()
      |> Enum.uniq()
    end

    def deps_tree_flat(_), do: nil

    def list_deps_by_size(sort_by \\ :app, paths \\ Mix.Project.deps_paths()) do
      deps_by_size(sort_by, paths)
      |> log(limit: :infinity)

      :ok
    end

    def deps_by_size(sort_by \\ :app, paths \\ Mix.Project.deps_paths()) do
      deps_tree()
      |> Enum.map(fn {app, deps} ->
        app_size =
          paths
          |> Map.get(app)
          |> List.wrap()
          # |> IO.inspect
          |> Mix.Utils.extract_files("*")
          |> Enum.map(&(File.stat(&1) |> ok_unwrap(%{}) |> Map.get(:size) || 0))
          |> Enum.sum()

        deps_size =
          deps
          |> Enum.map(&Map.get(paths, &1))
          # |> IO.inspect
          |> Mix.Utils.extract_files("*")
          |> Enum.map(&(File.stat(&1) |> ok_unwrap(%{}) |> Map.get(:size) || 0))
          |> Enum.sum()

        {app,
         if sort_by != :app do
           %{
             deps_list: deps,
             app: app_size,
             deps: deps_size,
             total: app_size + deps_size
           }
         else
           %{
             app: app_size,
             deps: deps_size,
             total: app_size + deps_size
           }
         end}
      end)
      |> Enum.sort_by(&(elem(&1, 1) |> Map.get(sort_by)), &>=/2)
      |> Enum.map(fn {app, meta} ->
        {app,
         Map.merge(meta, %{
           app: format_byte_size(meta.app),
           deps: format_byte_size(meta.deps),
           total: format_byte_size(meta.total)
         })}
      end)
    end

    def format_byte_size(byte_size) do
      System.cmd("numfmt", ["--to=iec-i", "--suffix=B", "--format=%9.2f", to_string(byte_size)])
      |> elem(0)
      |> String.trim()
    end

    @doc """
    Unwraps an `{:ok, val}` tuple, returning the value, or returns a fallback value (nil by default) if the tuple is `{:error, _}` or `:error`.
    """
    def ok_unwrap(val, fallback \\ nil)
    def ok_unwrap({:ok, val}, _fallback), do: val

    def ok_unwrap({:error, val}, fallback) do
      log(val)
      fallback
    end

    def ok_unwrap(:ok, fallback), do: fallback
    def ok_unwrap(:error, fallback), do: fallback
    def ok_unwrap(val, fallback), do: val || fallback

    def log(thing, opts \\ [])
    def log(thing, label) when is_binary(label), do: log(thing, label: label)

    def log(thing, opts) do
      if System.get_env("MIX_QUIET") != "1" do
        IO.inspect(thing, opts)
      else
        thing
      end
    end
  end
end
