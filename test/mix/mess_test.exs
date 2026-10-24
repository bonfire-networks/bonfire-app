defmodule Bonfire.MessTest do
  use ExUnit.Case, async: true

  @moduletag :backend
  @moduletag :tmp_dir

  @sha "cf068f79a8912370ff89fd584678acc3f94d3b13"

  # mirrors the order Mixer.mess_sources/1 builds in CI: the current flavour's files, then the base flavour's
  defp sources(dir) do
    [
      [git: Path.join(dir, "flavour.git"), hex: Path.join(dir, "flavour.hex")],
      [path: Path.join(dir, "base.path")],
      [git: Path.join(dir, "base.git"), hex: Path.join(dir, "base.hex")]
    ]
  end

  defp write!(dir, files), do: Enum.each(files, fn {name, body} -> File.write!(Path.join(dir, name), body) end)

  defp deps(dir), do: Mess.deps(sources(dir), [], use_local_clones?: true, use_umbrella?: false)

  defp find(deps, name), do: Enum.find(deps, &(elem(&1, 0) == name))

  test "a git dep in a later source wins over a hex dep in an earlier source", %{tmp_dir: dir} do
    write!(dir, %{
      "flavour.hex" => ~s(foo = "~> 1.0"\n),
      "base.git" => ~s(foo = "https://github.com/x/foo##{@sha}"\n)
    })

    assert {:foo, opts} = find(deps(dir), :foo)
    assert opts[:git] == "https://github.com/x/foo"
    assert opts[:ref] == @sha
  end

  test "a path dep in a later source wins over a git dep in an earlier source", %{tmp_dir: dir} do
    local = Path.join(dir, "foo")
    File.mkdir_p!(local)
    # Mess drops path deps without a mix.exs
    File.write!(Path.join(local, "mix.exs"), "")

    write!(dir, %{
      "flavour.git" => ~s(foo = "https://github.com/x/foo"\n),
      "base.path" => ~s(foo = "#{local}"\n)
    })

    assert {:foo, opts} = find(deps(dir), :foo)
    assert opts[:path] == local
  end

  test "among deps of the same kind, the earlier source wins", %{tmp_dir: dir} do
    write!(dir, %{
      "flavour.git" => ~s(foo = "https://github.com/flavour/foo"\n),
      "base.git" => ~s(foo = "https://github.com/base/foo"\n)
    })

    assert {:foo, opts} = find(deps(dir), :foo)
    assert opts[:git] == "https://github.com/flavour/foo"
  end

  test "a dep only listed in hex keeps its version", %{tmp_dir: dir} do
    write!(dir, %{"base.hex" => ~s(bar = "~> 2.0"\n)})

    assert {:bar, "~> 2.0", _opts} = find(deps(dir), :bar)
  end
end
