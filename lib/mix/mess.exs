# Copyright (c) 2020 James Laver, mess Contributors
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

    @doc "Takes a list of sources and an extra list of dependencies, and returns a new list of unique dependencies that include the packages specified in the sources. The sources list specifies where to find the list(s) of dependencies (if none are specified default paths are used, see `sources/1`). Each source is a keyword list of a source type and the path to the file where those type of dependencies are specified. The possible source types are path, git, and hex."
    def deps(sources \\ nil, extra_deps, opts \\ []) do
      opts = opts(opts)

      (sources || sources(opts[:use_local_forks?]))
      |> enum_deps()
      # |> IO.inspect(label: "enum_deps")
      |> deps_packages(extra_deps, opts)

      # |> IO.inspect(label: "deps_packages")
    end

    defp sources(true), do: [path: "deps.path", git: "deps.git", hex: "deps.hex"]
    defp sources(_), do: [git: "deps.git", hex: "deps.hex"]

    defp opts(opts) do
      opts =
        opts
        |> Keyword.put_new_lazy(:use_local_forks?, fn ->
          System.get_env("WITH_FORKS", "1") == "1"
        end)

      # NOTE: we check MIX_ENV instead of `Mix.env` because it incorrectly returns :prod when doing deps.get
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

      # |> IO.inspect(label: "opts for #{File.cwd!}")
    end

    defp enum_deps({:disabled, sublist}) do
      if Bonfire.Mixer.compile_disabled?() do
        sublist
        |> Enum.flat_map(&enum_deps/1)
        |> Enum.map(&Map.put(&1, :disabled, true))

        # |> IO.inspect(label: "disabled")
      else
        []
      end
    end

    defp enum_deps({kind, path}) do
      maybe_read(path, kind)
    end

    defp enum_deps(sublist) when is_list(sublist) do
      sublist
      |> Enum.flat_map(&enum_deps/1)
    end

    defp deps_packages(packages, extra_deps, opts),
      do:
        (Enum.flat_map(packages, &dep_spec(&1, opts)) ++ extra_deps)
        |> deps_uniq(opts)
        |> maybe_filter_umbrella(opts)

    defp deps_uniq(packages, opts),
      do:
        packages
        |> Enum.reject(&is_nil/1)
        # |> IO.inspect(label: "non-unique")
        |> maybe_filter_invalid_paths(opts)
        |> Enum.uniq_by(&elem(&1, 0))

    defp maybe_filter_invalid_paths(deps, _opts) do
      Enum.reject(deps, fn dep ->
        dep_opts = elem(dep, 1)
        is_list(dep_opts) and dep_opts[:path] && not File.exists?("#{dep_opts[:path]}/mix.exs")
      end)
    end

    defp maybe_filter_umbrella(deps, opts) do
      cond do
        opts[:umbrella_root?] ->
          Enum.reject(deps, fn dep ->
            dep_opts = elem(dep, 1)
            is_list(dep_opts) and dep_opts[:from_umbrella]
          end)

        # |> IO.inspect(label: "umbrella_root")

        opts[:umbrella_only] ->
          Enum.filter(deps, fn dep ->
            dep_opts = elem(dep, 1)
            is_list(dep_opts) and dep_opts[:from_umbrella]
          end)

        # |> IO.inspect(label: "umbrella_only")

        opts[:use_umbrella?] ->
          umbrella_deps = read_umbrella(opts)
          # |> IO.inspect(label: "umbrella_deps for #{File.cwd!}")

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
                  {
                    name,
                    dep_opts
                    # |> Keyword.put(:path, "../../#{dep_opts[:path]}")
                  }
                end
            end
          end)

        # |> IO.inspect(label: "in_umbrella")
        true ->
          deps
      end
    end

    def read_umbrella(opts) do
      config_dir = opts[:config_dir] || "../../config/"
      path = "#{config_dir}deps.path"

      if opts[:use_local_forks?] and File.exists?(path) do
        [path, "#{config_dir}deps.flavour.path"]
        |> Enum.flat_map(&maybe_read(&1, :path))
        |> Enum.flat_map(&dep_spec(&1, opts))
      else
        if opts[:use_local_forks?], do: IO.warn("could not load #{path}")
        []
      end
    end

    defp maybe_read(path, kind) when is_binary(path), do: have_read(File.read(path), path, kind)

    defp have_read({:error, :enoent}, _path, _kind) do
      # IO.puts("Could not read deps list from #{path} in #{File.cwd!()}")
      []
    end

    defp have_read({:error, error}, path, _kind) do
      IO.puts("Could not read deps list from #{path}: #{inspect(error)}")
      []
    end

    defp have_read({:ok, file}, _, kind),
      do: Enum.map(String.split(file, @newline), &read_line(&1, kind))

    defp read_line(line, kind),
      do: Map.put(Regex.named_captures(@parser, line), :kind, kind)

    defp dep_spec(%{"package" => ""}, _opts), do: []

    defp dep_spec(%{"package" => p, "value" => v, :kind => :hex} = params, _opts),
      do: pkg(p, v, override: true, runtime: !params[:disabled])

    defp dep_spec(%{"package" => p, "value" => v, :kind => :path} = params, opts) do
      umbrella_path = opts[:umbrella_path]

      if umbrella_path && String.starts_with?(v, umbrella_path) do
        if opts[:umbrella_root?] do
          pkg(p,
            from_umbrella: true,
            override: true,
            path: "../../#{v}",
            runtime: !params[:disabled]
          )

          # |> IO.inspect(label: "from_umbrella: #{p}")
        else
          pkg(p, in_umbrella: true, override: true, runtime: !params[:disabled])
          # |> IO.inspect(label: "in_umbrella: #{p}")
        end
      else
        pkg(p, path: v, override: true, runtime: !params[:disabled])
      end
    end

    defp dep_spec(%{"package" => p, "value" => v, :kind => :git} = params, _opts),
      do: git(v, p, !params[:disabled])

    defp git(line, p, runtime) when is_binary(line),
      do: git(Regex.named_captures(@git_branch, line), p, runtime)

    defp git(%{"branch" => "", "repo" => r}, p, runtime),
      do: pkg(p, git: r, override: true, runtime: runtime)

    defp git(%{"branch" => b, "repo" => r}, p, runtime),
      do: pkg(p, git: r, branch: b, override: true, runtime: runtime)

    defp pkg(name, opts), do: [{String.to_atom(name), opts}]
    defp pkg(name, version, opts), do: [{String.to_atom(name), version, opts}]
  end
end
