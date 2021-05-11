Code.eval_file("mess.exs")
defmodule Bonfire.MixProject do

  use Mix.Project

  def project do
    [
      app: :bonfire,
      version: "0.1.0-alpha.78",
      elixir: "~> 1.11",
      elixirc_paths: elixirc_paths(Mix.env()) |> IO.inspect,
      test_paths: test_paths(),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      config_path: config_path("config.exs"),
      releases: [
        bonfire: [runtime_config_path: config_path("runtime.exs")],
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
    Mess.deps(mess_sources(), [
      ## password hashing - builtin vs nif
      {:pbkdf2_elixir, "~> 1.2.1", only: [:dev, :test]},
      {:argon2_elixir, "~> 2.3.0", only: [:prod]},
      ## dev conveniences
      # {:dbg, "~> 1.0", only: [:dev, :test]},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:exsync, "~> 0.2", only: :dev},

      # tests
      {:floki, ">= 0.0.0", only: [:dev, :test]},
      {:ex_machina, "~> 2.4", only: :test},
      {:mock, "~> 0.3.0", only: :test},
      {:zest, "~> 0.1"},
      # {:grumble, "~> 0.1.3", only: [:test]},

      # list dependencies & licenses
      {:licensir, only: :dev, runtime: false,
        git: "https://github.com/mayel/licensir", branch: "pr",
        # path: "./forks/licensir"
      },

      # Testing a component library for liveview
      # {:surface_catalogue, "~> 0.0.7", only: :dev},

      # security auditing
      # {:mix_audit, "~> 0.1", only: [:dev], runtime: false}
      {:sobelow, "~> 0.8", only: :dev}
    ])
    # |> IO.inspect()
  end

  defp deps(test) when is_atom(test), do: deps(&dep?(test, &1))
  defp deps(test) when is_function(test, 1), do: Enum.filter(deps(), test)

  defp aliases do
    [
      "hex.setup": ["local.hex --force"],
      "rebar.setup": ["local.rebar --force"],
      "js.deps.get": [
        "cmd npm install --prefix assets",
        # "cmd npm install --prefix "<>existing_dep_path("bonfire_geolocate")<>"/assets"
      ],
      "js.deps.update": ["cmd npm update --prefix assets"],
      "ecto.seeds": [
        # "phil_columns.seed",
        "run #{flavour_path()}/repo/seeds.exs"
        ],
      "bonfire.deps": ["bonfire.deps.update", "bonfire.deps.clean"],
      setup: ["hex.setup", "rebar.setup", "deps.get", "bonfire.deps.clean", "ecto.setup", "js.deps.get"],
      updates: ["deps.get", "bonfire.deps", "js.deps.get"],
      upgrade: ["updates", "ecto.migrate"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "ecto.seeds"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "ecto.seeds", "test"]
    ]
  end

  defp flavour_path(), do: System.get_env("BONFIRE_FLAVOUR", "flavours/"<>System.get_env("FLAVOUR", "classic"))

  defp config_path(flavour_path \\ flavour_path(), filename),
    do: Path.expand(Path.join([flavour_path, "config", filename]))

  defp mess_sources() do
    mess_sources(System.get_env("WITH_FORKS","1"))
    |> Enum.map(fn {k,v} -> {k, config_path(v)} end)
  end

  defp mess_sources("0"), do: [git: "deps.git", hex: "deps.hex"]
  defp mess_sources(_),   do: [path: "deps.path", git: "deps.git", hex: "deps.hex"]

  defp dep_path(dep) do
    spec = elem(dep, 1)
    if is_list(spec) && spec[:path],
      do: spec[:path],
      else: Mix.Project.deps_path() <> "/" <> dep_name(dep)
  end

  defp dep_paths(dep, extra) when is_list(extra), do: Enum.flat_map(extra, &dep_paths(dep, &1))
  defp dep_paths(dep, extra) when is_binary(extra) do
    path = Path.join(dep_path(dep), extra)
    # IO.inspect(path)
    # IO.inspect(File.ls(path))
    if File.exists?(path), do: [path], else: []
  end

  defp test_paths(), do: ["test" | Enum.flat_map(deps(:test), &dep_paths(&1, "test"))]
  defp test_lib_paths(), do: ["lib", "test/support" | Enum.flat_map(deps(:test), &dep_paths(&1, "test/support"))]

  @test_deps [:pointers]

  defp dep?(:test, dep), do: elem(dep, 0) in @test_deps || String.starts_with?(dep_name(dep), "bonfire_")

  defp dep_name(dep), do: Atom.to_string(elem(dep, 0))

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: test_lib_paths()
  defp elixirc_paths(_), do: ["lib"]

end
