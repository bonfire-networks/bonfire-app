defmodule Mix.Tasks.Bonfire.Dep.Compile do
  use Mix.Task

  @shortdoc "Compiles dependencies"

  @moduledoc """
  Compiles dependencies.

  By default, compile all dependencies. A list of dependencies
  can be given compile multiple dependencies in order.

  This task attempts to detect if the project contains one of
  the following files and act accordingly:

    * `mix.exs`      - invokes `mix compile`
    * otherwise skip

  If a list of dependencies is given, Mix will attempt to compile
  them as is. For example, if project `a` depends on `b`, calling
  `mix deps.compile a` will compile `a` even if `b` is out of
  date. This is to allow parts of the dependency tree to be
  recompiled without propagating those changes upstream. To ensure
  `b` is included in the compilation step, pass `--include-children`.
  """

  import Mix.Dep, only: [available?: 1, mix?: 1]

  @switches [include_children: :boolean, force: :boolean]

  @spec run(OptionParser.argv) :: :ok
  def run(args) do
    unless "--no-archives-check" in args do
      Mix.Task.run "archive.check", args
    end

    Mix.Project.get!

    case OptionParser.parse(args, switches: @switches) do
      {opts, [], _} ->
        # Because this command may be invoked explicitly with
        # deps.compile, we simply try to compile any available
        # dependency.
        compile(Enum.filter(loaded_deps(), &available?/1), opts)
      {opts, tail, _} ->
        compile(loaded_by_name(tail, [env: Mix.env] ++ opts), opts)
    end
  end

  @doc false
  def compile(deps, options \\ []) do
    shell  = Mix.shell
    config = Mix.Project.deps_config

    Mix.Task.run "deps.precompile"

    compiled =
      Enum.map(deps, fn %Mix.Dep{app: app, status: status, opts: opts, scm: scm} = dep ->

        check_unavailable!(app, status)

        compiled? = cond do
          mix?(dep) ->
            maybe_clean(dep, options)
            do_mix dep, config
          true ->
            shell.error "Could not compile #{inspect app}, no \"mix.exs\" found " <>
              "(pass :compile as an option to customize compilation, set it to \"false\" to do nothing)"
            false
        end

        # We should touch fetchable dependencies even if they
        # did not compile otherwise they will always be marked
        # as stale, even when there is nothing to do.
        fetchable? = touch_fetchable(scm, opts[:build])

        compiled? and fetchable?

      end)

    if true in compiled, do: Mix.Task.run("will_recompile"), else: :ok
  end

  defp maybe_clean(dep, opts) do
    # If a dependency was marked as fetched or with an out of date lock
    # or missing the app file, we always compile it from scratch.
    if Keyword.get(opts, :force, false) or Mix.Dep.compilable?(dep) do
      File.rm_rf!(Path.join([Mix.Project.build_path(), "lib", Atom.to_string(dep.app)]))
    end
  end

  defp touch_fetchable(scm, path) do
    if scm.fetchable? do
      File.mkdir_p!(path)
      File.touch!(Path.join(path, ".compile.fetch"))
      true
    else
      false
    end
  end

  defp check_unavailable!(app, {:unavailable, _}) do
    Mix.raise "Cannot compile dependency #{inspect app} because " <>
      "it isn't available, run \"mix deps.get\" first"
  end

  defp check_unavailable!(_, _) do
    :ok
  end

  defp do_mix(dep, _config) do
    Mix.Dep.in_dependency dep, fn _ ->
      if req = old_elixir_req(Mix.Project.config) do
        Mix.shell.error "warning: the dependency #{inspect dep.app} requires Elixir #{inspect req} " <>
                        "but you are running on v#{System.version}"
      end

      Mix.shell.info "Recompiling extension #{inspect dep.app}"

      try do

        # If "compile" was never called, the reenabling is a no-op and
        # "compile.elixir" is a no-op as well (because it wasn't reenabled after
        # running "compile"). If "compile" was already called, then running
        # "compile" is a no-op and running "compile.elixir" will work because we
        # manually reenabled it.
        Mix.Task.reenable("compile.elixir")
        Mix.Task.reenable("compile.leex")
        Mix.Task.reenable("compile.all")
        Mix.Task.reenable("compile")

        options = [
          # "--force",
          "--no-deps-loading",
          "--no-apps-loading",
          "--no-archives-check",
          "--no-elixir-version-check",
          "--no-warnings-as-errors"
        ]

        res = Mix.Task.run("compile", options)

        # Mix.shell.info(inspect res)

        match?({:ok, _}, res)

      catch
        kind, reason ->
          stacktrace = System.stacktrace
          app = dep.app
          Mix.shell.error "could not compile dependency #{inspect app}, \"mix compile\" failed. " <>
            "You can recompile this dependency with \"mix deps.compile #{app}\", update it " <>
            "with \"mix deps.update #{app}\" or clean it with \"mix deps.clean #{app}\""
          :erlang.raise(kind, reason, stacktrace)
      end
    end
  end

  defp old_elixir_req(config) do
    req = config[:elixir]
    if req && not Version.match?(System.version, req) do
      req
    end
  end

  defp loaded_deps() do
    if Keyword.has_key?(Mix.Dep.__info__(:functions), :cached) do
      Mix.Dep.cached()
    else
      Mix.Dep.loaded()
    end
  end

  @doc """
  Receives a list of dependency names and returns loaded `Mix.Dep`s.
  Logs a message if the dependency could not be found.
  ## Exceptions
  This function raises an exception if any of the dependencies
  provided in the project are in the wrong format.
  """
  def loaded_by_name(given, all_deps \\ nil, opts) do
    all_deps = all_deps || loaded_deps()

    # Ensure all apps are atoms
    apps = to_app_names(given)
    deps =
      if opts[:include_children] do
        get_deps_with_children(all_deps, apps)
      else
        get_deps(all_deps, apps)
      end

    Enum.each apps, fn(app) ->
      unless Enum.any?(all_deps, &(&1.app == app)) do
        Mix.raise "Unknown dependency #{app} for environment #{Mix.env}"
      end
    end

    deps
  end

  defp to_app_names(given) do
    Enum.map given, fn(app) ->
      if is_binary(app), do: String.to_atom(app), else: app
    end
  end

  defp get_deps(all_deps, apps) do
    Enum.filter(all_deps, &(&1.app in apps))
  end

  defp get_deps_with_children(all_deps, apps) do
    deps = get_children(all_deps, apps)
    apps = deps |> Enum.map(& &1.app) |> Enum.uniq
    get_deps(all_deps, apps)
  end

  defp get_children(_all_deps, []), do: []
  defp get_children(all_deps, apps) do
    # Current deps
    deps = get_deps(all_deps, apps)

    # Children apps
    apps = for %{deps: children} <- deps,
               %{app: app} <- children,
               do: app

    # Current deps + children deps
    deps ++ get_children(all_deps, apps)
  end

end
