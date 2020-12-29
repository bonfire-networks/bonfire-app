Code.eval_file("mess.exs")
defmodule Bonfire.MixProject do

  use Mix.Project

  @bonfire_deps [
    "pointers",
    "activity_pub",
    "bonfire_common",
    "bonfire_data_access_control",
    "bonfire_data_identity",
    "bonfire_data_social",
    "bonfire_data_activity_pub",
    "bonfire_me",
    "bonfire_ui_social",
    # "bonfire_geolocate",
    # "bonfire_quantify",
    # "bonfire_valueflows",
    # "bonfire_ui_valueflows",
  ]

  def project do
    [
      app: :bonfire,
      version: "0.1.0",
      elixir: "~> 1.11",
      elixirc_paths: elixirc_paths(Mix.env()),
      test_paths: ["test"] ++ existing_dep_paths(@bonfire_deps, "test"),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end


  defp deps() do
    Mess.deps([
      ## password hashing - builtin vs nif
      {:pbkdf2_elixir, "~> 1.2", only: [:dev, :test]},
      {:argon2_elixir, "~> 2.3", only: [:prod]},
      ## dev conveniences
      {:dbg, "~> 1.0", only: [:dev, :test]},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:exsync, "~> 0.2", only: :dev},
      # tests
      {:floki, ">= 0.0.0", only: [:dev, :test]},
      {:ex_machina, "~> 2.4", only: :test},
      {:mock, "~> 0.3.0", only: :test},
      {:zest, "~> 0.1"},
    ])
    # |> IO.inspect()
  end


  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"] ++ existing_dep_paths(@bonfire_deps, "test/support")
  defp elixirc_paths(_), do: ["lib"]


  def application do
    [
      mod: {Bonfire.Application, []},
      extra_applications: [:logger, :runtime_tools, :ssl, :bamboo, :bamboo_smtp]
    ]
  end

  @bonfire_deps_str @bonfire_deps |> Enum.join(" ")

  defp aliases do
    [
      "hex.setup": ["local.hex --force"],
      "rebar.setup": ["local.rebar --force"],
      "js.deps.get": ["cmd npm install --prefix assets"],
      "js.deps.update": ["cmd npm update --prefix assets"],
      "ecto.seeds": ["run priv/repo/seeds.exs"],
      "bonfire.deps.update": ["deps.update #{@bonfire_deps_str}"],
      "bonfire.deps.clean": ["deps.clean #{@bonfire_deps_str} --build"],
      "bonfire.deps": ["bonfire.deps.update", "bonfire.deps.clean"],
      setup: ["hex.setup", "rebar.setup", "deps.get", "bonfire.deps.clean", "ecto.setup", "js.deps.get"],
      updates: ["deps.get", "bonfire.deps", "ecto.migrate", "js.deps.get"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "ecto.seeds"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"]
    ]
  end

  defp dep_path(dep) do
    # use locally cloned repo if path defined and active, otherwise stick to code obtained by mix deps.get
    deps()[String.to_existing_atom(dep)][:path] || "./deps/"<>dep
  end

  defp existing_dep_paths(list, path) do
    Enum.map(list, fn dep -> dep_path(dep) <>"/"<>path end)
    |> existing_paths()
    # |> IO.inspect()
  end

  defp existing_paths(list) do
    Enum.filter(list, &File.exists?(&1))
  end

end
