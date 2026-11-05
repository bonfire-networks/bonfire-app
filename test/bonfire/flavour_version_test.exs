defmodule Bonfire.FlavourVersionTest do
  @moduledoc """
  A distribution built as a Bonfire flavour can show its own version (the one in the flavour's own `mix.exs`) next to Bonfire's, once its config sets `config :bonfire, :flavour_overrides, version: true`. Off by default, so stock flavours (all at a placeholder `0.0.1`) look as they always have.
  """
  use ExUnit.Case, async: false

  @moduletag :backend

  setup do
    previous = for key <- [:flavour, :app_name], do: {key, Application.fetch_env(:bonfire, key)}

    on_exit(fn ->
      for {key, value} <- previous do
        case value do
          {:ok, value} -> Application.put_env(:bonfire, key, value)
          :error -> Application.delete_env(:bonfire, key)
        end
      end
    end)
  end

  # `APP_NAME` renames the distribution, not the software it runs on: it names the flavour, and Bonfire stays Bonfire
  describe "flavour_name/0" do
    test "is APP_NAME when an instance sets one" do
      Application.put_env(:bonfire, :flavour, "federated_archives")
      Application.put_env(:bonfire, :app_name, "Federated Archives Alliance")

      assert "Federated Archives Alliance" == Bonfire.Application.flavour_name()
    end

    test "is the flavour's own name when APP_NAME is the default" do
      Application.put_env(:bonfire, :flavour, "federated_archives")
      Application.put_env(:bonfire, :app_name, Bonfire.Application.project()[:name])

      assert "federated archives" == Bonfire.Application.flavour_name()
    end
  end

  # what a flavour's config sets with `config :bonfire, :flavour_overrides, version: true`
  defp show_flavour_version, do: Process.put([:bonfire, :flavour_overrides, :version], true)

  test "is nil when the flavour's config does not turn it on" do
    Application.put_env(:bonfire, :flavour, "ember")

    assert nil == Bonfire.Application.flavour_version()
  end

  test "is the version of the flavour's own app when turned on" do
    # ember is always a dependency (the base flavour), so it is loaded in every build
    Application.put_env(:bonfire, :flavour, "ember")
    show_flavour_version()

    assert version = Bonfire.Application.flavour_version()
    assert version == to_string(Application.spec(:ember, :vsn))
  end

  test "is nil for a flavour that is not a loaded app" do
    Application.put_env(:bonfire, :flavour, "not_a_flavour_#{System.unique_integer([:positive])}")
    show_flavour_version()

    assert nil == Bonfire.Application.flavour_version()
  end
end
