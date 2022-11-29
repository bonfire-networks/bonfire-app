# Copyright (c) 2020 James Laver, mess Contributors
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
if not Code.ensure_loaded?(Mess) do
  defmodule Mess do
    @sources [path: "deps.path", git: "deps.git", hex: "deps.hex"]

    @newline ~r/(?:\r\n|[\r\n])/
    @parser ~r/^(?<indent>\s*)((?<package>[a-z_][a-z0-9_]+)\s*=\s*"(?<value>[^"]+)")?(?<post>.*)/
    @git_branch ~r/(?<repo>[^#]+)(#(?<branch>.+))?/

    def umbrella_path(opts \\ []),
      do: opts[:umbrella_path] || if(Mix.env() != :prod, do: "extensions/", else: nil)

    def deps(sources \\ @sources, extra_deps, opts \\ []),
      do: Enum.flat_map(sources, fn {k, v} -> read(v, k) end) |> deps_packages(extra_deps, opts)

    defp deps_packages(packages, extra_deps, opts),
      do: Enum.flat_map(packages, &dep_spec(&1, opts)) |> deps_uniq(extra_deps, opts)

    defp deps_uniq(packages, extra_deps, opts),
      do: Enum.uniq_by(packages ++ extra_deps, &elem(&1, 0)) |> maybe_filter_umbrella(opts)

    defp maybe_filter_umbrella(deps, opts) do
      if opts[:umbrella_root?] do
        Enum.reject(deps, fn dep ->
          dep_opts = elem(dep, 1)
          is_list(dep_opts) and dep_opts[:from_umbrella]
        end)

        # |> IO.inspect(label: "umbrella_root")
      else
        if umbrella_path(opts) do
          umbrella_deps = read_umbrella("../../config/deps.path", opts)

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
                  {name, dep_opts |> Keyword.put(:path, "../../#{dep_opts[:path]}")}
                end
            end
          end)

          # |> IO.inspect(label: "in_umbrella")
        else
          deps
        end
      end
    end

    defp read_umbrella(path, opts) when is_binary(path) do
      if File.exists?(path) do
        read(path, :path)
        |> Enum.flat_map(&dep_spec(&1, opts))
      else
        []
      end
    end

    defp read(path, kind) when is_binary(path), do: have_read(File.read(path), kind)

    defp have_read({:error, :enoent}, _kind), do: []

    defp have_read({:ok, file}, kind),
      do: Enum.map(String.split(file, @newline), &read_line(&1, kind))

    defp read_line(line, kind),
      do: Map.put(Regex.named_captures(@parser, line), :kind, kind)

    defp dep_spec(%{"package" => ""}, _opts), do: []

    defp dep_spec(%{"package" => p, "value" => v, :kind => :hex}, _opts),
      do: pkg(p, v, override: true)

    defp dep_spec(%{"package" => p, "value" => v, :kind => :path}, opts) do
      umbrella_path = umbrella_path(opts)

      if umbrella_path && String.starts_with?(v, umbrella_path) do
        pkg(p, from_umbrella: true, override: true, path: v)
      else
        pkg(p, path: v, override: true)
      end
    end

    defp dep_spec(%{"package" => p, "value" => v, :kind => :git}, _opts), do: git(v, p)

    defp git(line, p) when is_binary(line),
      do: git(Regex.named_captures(@git_branch, line), p)

    defp git(%{"branch" => "", "repo" => r}, p),
      do: pkg(p, git: r, override: true)

    defp git(%{"branch" => b, "repo" => r}, p),
      do: pkg(p, git: r, branch: b, override: true)

    defp pkg(name, opts), do: [{String.to_atom(name), opts}]
    defp pkg(name, version, opts), do: [{String.to_atom(name), version, opts}]
  end
end
