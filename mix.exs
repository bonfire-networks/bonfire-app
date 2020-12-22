Code.eval_file("mess.exs")
defmodule Bonfire.MixProject do

  use Mix.Project

  def project do
    [
      app: :bonfire,
      version: "0.1.0",
      elixir: "~> 1.11",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: Mess.deps [
        ## password hashing - builtin vs nif
        {:pbkdf2_elixir, "~> 1.2.1", only: [:dev, :test]},
        {:argon2_elixir, "~> 2.3.0", only: [:prod]},
        ## dev conveniences
        {:dbg, "~> 1.0", only: [:dev, :test]},
        {:phoenix_live_reload, "~> 1.2", only: :dev},
        {:exsync, "~> 0.2", only: :dev},
        # tests
        {:floki, ">= 0.0.0", only: [:dev, :test]},
      ]
    ]
  end

  def application do
    [
      mod: {Bonfire.Application, []},
      extra_applications: [:logger, :runtime_tools, :ssl, :bamboo, :bamboo_smtp]
    ]
  end

  defp deps() do
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  @bonfire_deps [
    "pointers",
    "bonfire_common",
    "bonfire_data_access_control",
    "bonfire_data_identity",
    "bonfire_data_social",
    "bonfire_data_activity_pub",
    "bonfire_me",
    "bonfire_geolocate",
    "bonfire_quantify",
    "bonfire_valueflows",
  ] |> Enum.join(" ")

  defp aliases do
    [
      "hex.setup": ["local.hex --force"],
      "rebar.setup": ["local.rebar --force"],
      "js.deps.get": ["cmd npm install --prefix assets"],
      "js.deps.update": ["cmd npm update --prefix assets"],
      "ecto.seeds": ["run priv/repo/seeds.exs"],
      "bonfire.deps.update": ["deps.update #{@bonfire_deps}"],
      "bonfire.deps.clean": ["deps.clean #{@bonfire_deps} --build"],
      "bonfire.deps": ["bonfire.deps.update", "bonfire.deps.clean"],
      setup: ["hex.setup", "rebar.setup", "deps.get", "bonfire.deps.clean", "ecto.setup", "js.deps.get"],
      updates: ["deps.get", "bonfire.deps", "ecto.migrate", "js.deps.get"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "ecto.seeds"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"]
    ]
  end

end
