# Copyright (c) 2025 mess Contributors
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
if not Code.ensure_loaded?(Mess) do
  defmodule Mess do
    @moduledoc """
    Helper for using dependencies specified in simpler text files in an Elixir mix project.
    """
    @newline ~r/(?:\r\n|[\r\n])/
    @parser ~r/^(?<indent>\s*)((?<package>[a-z_][a-z0-9_]+)\s*=\s*"(?<value>[^"]+)")?(?<post>.*)/
    @git_branch ~r/(?<repo>[^#]+)(#(?<branch>.+))?/
    @ext_forks_path System.get_env("FORKS_PATH", "extensions/")

    @doc """
    Takes a list of sources and an extra list of dependencies, and returns a new list of unique dependencies that include the packages specified in the sources.
    The sources list specifies where to find the list(s) of dependencies (if none are specified default paths are used, see `sources/1`).
    Each source is a keyword list of a source type and the path to the file where those type of dependencies are specified.
    The possible source types are path, git, and hex.

    ## Example

        iex> Mess.deps([{:path, "deps.path"}, {:git, "deps.git"}], [], [])
        [{:some_dep, "~> 1.0"}]
    """
    def deps(sources \\ nil, extra_deps, opts \\ []) do
      opts = opts(opts)

      (sources || sources(opts[:use_local_forks?]))
      |> enum_deps()
      |> deps_packages(extra_deps, opts)
    end

    @doc """
    Returns the default sources based on whether local forks are used.
    """
    def sources(true), do: [path: "deps.path", git: "deps.git", hex: "deps.hex"]
    def sources(_), do: [git: "deps.git", hex: "deps.hex"]

    @doc """
    Prepares the options by adding default values for `use_local_forks?`, `use_umbrella?`, and `umbrella_path`.
    """
    def opts(opts) do
      opts =
        opts
        |> Keyword.put_new_lazy(:use_local_forks?, fn ->
          System.get_env("WITH_FORKS", "1") == "1"
        end)

      opts =
        opts
        |> Keyword.put_new_lazy(:use_umbrella?, fn ->
          System.get_env("MIX_ENV", "dev") == "dev" and opts[:use_local_forks?] and
            System.get_env("AS_UMBRELLA") == "1"
        end)

      opts
      |> Keyword.put_new_lazy(:umbrella_path, fn ->
        if opts[:use_umbrella?], do: @ext_forks_path, else: nil
      end)
    end

    @doc """
    Enumerates dependencies from a list of sources.

    ## Example

        iex> Mess.enum_deps({:path, "deps.path"})
        [%{"package" => "some_dep", "value" => "~> 1.0", kind: :path}]
    """
    def enum_deps({:disabled, sublist}) do
      if Bonfire.Mixer.compile_disabled?() do
        sublist
        |> Enum.flat_map(&enum_deps/1)
        |> Enum.map(&Map.put(&1, :disabled, true))
      else
        []
      end
    end

    def enum_deps({kind, path}) do
      maybe_read(path, kind)
    end

    def enum_deps(sublist) when is_list(sublist) do
      sublist
      |> Enum.flat_map(&enum_deps/1)
    end

    @doc """
    Combines and filters dependencies to ensure uniqueness and validity.

    ## Example

        iex> Mess.deps_packages([%{"package" => "some_dep", "value" => "~> 1.0", kind: :path}], [], [])
        [{:some_dep, "~> 1.0"}]
    """
    def deps_packages(packages, extra_deps, opts) do
      (Enum.flat_map(packages, &dep_spec(&1, opts)) ++ extra_deps)
      |> deps_uniq(opts)
      |> maybe_filter_umbrella(opts)
    end

    @doc """
    Filters out nil values and ensures unique dependencies.

    ## Example

        iex> Mess.deps_uniq([{:some_dep, "~> 1.0"}, {:some_dep, "~> 1.0"}], [])
        [{:some_dep, "~> 1.0"}]
    """
    def deps_uniq(packages, opts) do
      packages
      |> Enum.reject(&is_nil/1)
      |> maybe_filter_invalid_paths(opts)
      |> Enum.uniq_by(&elem(&1, 0))
    end

    @doc """
    Filters out dependencies with invalid paths.
    """
    def maybe_filter_invalid_paths(deps, _opts) do
      Enum.reject(deps, fn dep ->
        dep_opts = elem(dep, 1)
        (is_list(dep_opts) and dep_opts[:path]) && not File.exists?("#{dep_opts[:path]}/mix.exs")
      end)
    end

    @doc """
    Filters dependencies based on umbrella settings.
    """
    def maybe_filter_umbrella(deps, opts) do
      cond do
        opts[:umbrella_root?] ->
          Enum.reject(deps, fn dep ->
            dep_opts = elem(dep, 1)
            is_list(dep_opts) and dep_opts[:from_umbrella]
          end)

        opts[:umbrella_only] ->
          Enum.filter(deps, fn dep ->
            dep_opts = elem(dep, 1)
            is_list(dep_opts) and dep_opts[:from_umbrella]
          end)

        opts[:use_umbrella?] ->
          umbrella_deps = read_umbrella(opts)

          deps
          |> Enum.map(fn dep ->
            name = elem(dep, 0)

            case umbrella_deps[name] do
              nil ->
                dep

              dep_opts ->
                if dep_opts[:from_umbrella] do
                  {name, in_umbrella: true, override: true}
                else
                  {name, dep_opts}
                end
            end
          end)

        true ->
          deps
      end
    end

    @doc """
    Reads umbrella dependencies from configuration files.
    """
    def read_umbrella(opts) do
      config_dir = opts[:config_dir] || "../../config/"
      path = "#{config_dir}deps.path"

      if opts[:use_local_forks?] and File.exists?(path) do
        [path, "#{config_dir}current_flavour/deps.path"]
        |> Enum.flat_map(&maybe_read(&1, :path))
        |> Enum.flat_map(&dep_spec(&1, opts))
      else
        if opts[:use_local_forks?], do: IO.warn("could not load #{path}")
        []
      end
    end

    @doc """
    Reads and parses a file containing dependency information.
    """
    def maybe_read(path, kind) when is_binary(path), do: have_read(File.read(path), path, kind)

    defp have_read({:error, :enoent}, _path, _kind), do: []

    defp have_read({:error, error}, path, _kind) do
      IO.puts("Could not read deps list from #{path}: #{inspect(error)}")
      []
    end

    defp have_read({:ok, file}, _, kind),
      do: Enum.map(String.split(file, @newline), &read_line(&1, kind))

    @doc """
    Parses a line from a dependency file.
    """
    def read_line(line, kind),
      do: Map.put(Regex.named_captures(@parser, line), :kind, kind)

    @doc """
    Converts a parsed dependency specification into a proper dependency tuple.
    """
    def dep_spec(%{"package" => ""}, _opts), do: []

    def dep_spec(%{"package" => p, "value" => v, :kind => :hex} = params, _opts),
      do: pkg(p, v, override: true, runtime: !params[:disabled])

    def dep_spec(%{"package" => p, "value" => v, :kind => :path} = params, opts) do
      umbrella_path = opts[:umbrella_path]

      if umbrella_path && String.starts_with?(v, umbrella_path) do
        if opts[:umbrella_root?] do
          pkg(p,
            from_umbrella: true,
            override: true,
            path: "../../#{v}",
            runtime: !params[:disabled]
          )
        else
          pkg(p, in_umbrella: true, override: true, runtime: !params[:disabled])
        end
      else
        pkg(p, path: v, override: true, runtime: !params[:disabled])
      end
    end

    def dep_spec(%{"package" => p, "value" => v, :kind => :git} = params, _opts),
      do: git(v, p, !params[:disabled])

    defp git(line, p, runtime) when is_binary(line),
      do: git(Regex.named_captures(@git_branch, line), p, runtime)

    defp git(%{"branch" => "", "repo" => r}, p, runtime),
      do: pkg(p, git: r, override: true, runtime: runtime)

    defp git(%{"branch" => b, "repo" => r}, p, runtime),
      do: pkg(p, git: r, branch: b, override: true, runtime: runtime)

    @doc """
    Constructs a dependency tuple.
    """
    def pkg(name, opts), do: [{String.to_atom(name), opts}]
    def pkg(name, version, opts), do: [{String.to_atom(name), version, opts}]
  end
end
