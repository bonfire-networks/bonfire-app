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

    def deps(sources \\ @sources, deps), do: deps(Enum.flat_map(sources, fn {k,v} -> read(v, k) end), deps, :deps)
    defp deps(packages, deps, :deps), do: deps(Enum.flat_map(packages, &dep_spec/1), deps, :uniq)
    defp deps(packages, deps, :uniq), do: Enum.uniq_by(deps ++ packages, &elem(&1, 0))

    defp read(path, kind) when is_binary(path), do: read(File.read(path), kind)
    defp read({:error, :enoent}, _kind), do: []
    defp read({:ok, file}, kind), do: Enum.map(String.split(file, @newline), &read_line(&1, kind))

    defp read_line(line, kind), do: Map.put(Regex.named_captures(@parser, line), :kind, kind)

    defp dep_spec(%{"package" => ""}), do: []
    defp dep_spec(%{"package" => p, "value" => v, :kind => :hex}), do: pkg(p, v, override: true)
    defp dep_spec(%{"package" => p, "value" => v, :kind => :path}), do: pkg(p, path: v, override: true)
    defp dep_spec(%{"package" => p, "value" => v, :kind => :git}), do: git(v, p)

    defp git(line, p) when is_binary(line), do: git(Regex.named_captures(@git_branch, line), p)
    defp git(%{"branch" => "", "repo" => r}, p), do: pkg(p, git: r, override: true)
    defp git(%{"branch" => b, "repo" => r}, p), do: pkg(p, git: r, branch: b, override: true)

    defp pkg(name, opts), do: [{String.to_atom(name), opts}]
    defp pkg(name, version, opts), do: [{String.to_atom(name), version, opts}]

  end
end
