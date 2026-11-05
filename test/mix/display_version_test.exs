defmodule Bonfire.DisplayVersionTest do
  @moduledoc """
  The version Bonfire reports can be renamed without a rebuild, so a release can be promoted from one stage to the next (beta to rc) under its own name.

  `config/runtime.exs` puts `BONFIRE_DISPLAY_VERSION` into the `:app_version` app env, and `Bonfire.Application.version/0` prefers it over the compiled version, which stays available as `Bonfire.Application.config()[:version]`.
  """
  use ExUnit.Case, async: false

  @moduletag :backend

  @env "BONFIRE_DISPLAY_VERSION"

  setup do
    previous_env = System.get_env(@env)
    previous_app_env = Application.fetch_env(:bonfire, :app_version)

    System.delete_env(@env)
    Application.delete_env(:bonfire, :app_version)

    on_exit(fn ->
      if previous_env, do: System.put_env(@env, previous_env), else: System.delete_env(@env)

      case previous_app_env do
        {:ok, value} -> Application.put_env(:bonfire, :app_version, value)
        :error -> Application.delete_env(:bonfire, :app_version)
      end
    end)
  end

  # a release built with the variable set (OTP tarballs, docker builds) keeps it in its env.sh, so it applies on every boot without anyone setting it, while one set at runtime still wins
  describe "rel/env.sh.eex" do
    defp render_env_sh, do: EEx.eval_file("rel/env.sh.eex", assigns: [release: %{name: :bonfire}])

    test "bakes in the display version set at build time, as a default" do
      System.put_env(@env, "9.9.9-test")

      assert render_env_sh() =~
               ~s(export BONFIRE_DISPLAY_VERSION="${BONFIRE_DISPLAY_VERSION:-9.9.9-test}")
    end

    test "adds nothing when the variable is unset or empty at build time" do
      refute render_env_sh() =~ "BONFIRE_DISPLAY_VERSION"

      System.put_env(@env, "")
      refute render_env_sh() =~ "BONFIRE_DISPLAY_VERSION"
    end
  end

  test "returns the compiled version when no override is set" do
    assert Bonfire.Application.version() == Bonfire.Application.config()[:version]
  end

  test "returns the app env override when it is set, and keeps the compiled version available" do
    compiled = Bonfire.Application.config()[:version]

    Application.put_env(:bonfire, :app_version, "9.9.9-test")

    assert "9.9.9-test" == Bonfire.Application.version()
    assert compiled == Bonfire.Application.config()[:version]
  end
end
