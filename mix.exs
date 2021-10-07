Code.eval_file("mess.exs")
defmodule Bonfire.MixProject do
  use Mix.Project

  @config [
      version: "0.1.0-beta.8", # note that the flavour will automatically be added where the dash appears
      elixir: "~> 1.12",
      default_flavour: "classic",
      test_deps_prefixes: ["bonfire_", "pointers", "paginator"],
      data_deps_prefixes: ["bonfire_data_", "pointers", "bonfire_tag", "bonfire_classify", "bonfire_geolocate"]
    ]

  def project do
    [
      app: :bonfire,
      version: version(),
      elixir: @config[:elixir],
      elixirc_paths: elixirc_paths(Mix.env()),
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
      extra_applications: [:logger, :runtime_tools, :os_mon, :ssl, :bamboo, :bamboo_smtp]
    ]
  end

  defp aliases do
    [
      "hex.setup": ["local.hex --force"],
      "rebar.setup": ["local.rebar --force"],
      "js.deps.get": ["cmd make js.deps.get"],
      "js.deps.update": ["cmd cd assets && pnpm update"],
      "assets.release": [
        "cmd cd ./assets && pnpm build",
      ],
      "ecto.seeds": [
        # "phil_columns.seed",
        "run #{flavour_path()}/repo/seeds.exs"
        ],
      "bonfire.deps.update": ["deps.update " <>deps_to_update()],
      "bonfire.deps.clean": ["deps.clean " <>deps_to_clean()<>" --build"],
      "bonfire.deps": ["bonfire.deps.update", "bonfire.deps.clean"],
      setup: ["hex.setup", "rebar.setup", "deps.get", "bonfire.deps.clean", "ecto.setup"],
      updates: ["deps.get", "bonfire.deps"],
      upgrade: ["updates", "ecto.migrate"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "ecto.seeds"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "ecto.seeds", "test"]
    ]

  end

  defp deps() do
    Mess.deps(mess_sources(), [
      ## password hashing - builtin vs nif
      {:pbkdf2_elixir, "~> 1.4", only: [:dev, :test]},
      {:argon2_elixir, "~> 2.4", only: [:prod]},
      ## dev conveniences
      # {:dbg, "~> 1.0", only: [:dev, :test]},
      {:phoenix_live_reload, "~> 1.3", only: :dev},
      {:exsync, "~> 0.2", only: :dev},

      # tests
      {:floki, ">= 0.0.0", only: [:dev, :test]},
      {:ex_machina, "~> 2.4", only: :test},
      {:mock, "~> 0.3", only: :test},
      {:zest, "~> 0.1"},
      {:grumble, "~> 0.1.3", only: [:test], override: true},
      {:bonfire_api_graphql, git: "https://github.com/bonfire-networks/bonfire_api_graphql", branch: "main", only: [:test]},
      {:mix_test_watch, "~> 1.0", only: :test, runtime: false},
      {:mix_test_interactive, "~> 1.0", only: :test, runtime: false},
      {:ex_unit_notifier, "~> 1.0", only: :test},

      # list dependencies & licenses
      {:licensir, only: :dev, runtime: false,
        git: "https://github.com/mayel/licensir", branch: "pr",
        # path: "./forks/licensir"
      },

      # security auditing
      # {:mix_audit, "~> 0.1", only: [:dev], runtime: false}
      {:sobelow, "~> 0.8", only: :dev}
      ]
    )

  end

  def catalogues do
    [
      "deps/surface/priv/catalogue",
      "forks/bonfire_ui_social/priv/catalogue"
    ]
  end


  def deps(deps \\ deps(), deps_subtype) when is_atom(deps_subtype), do:
    Enum.filter(deps, &include_dep?(deps_subtype, &1))

  def flavour_path(), do:
    System.get_env("FLAVOUR_PATH", "flavours/"<>flavour())

  def flavour(), do:
    System.get_env("FLAVOUR", @config[:default_flavour])

  def config_path(flavour_path \\ flavour_path(), filename),
    do: Path.expand(Path.join([flavour_path, "config", filename]))

  def forks_path(), do: System.get_env("LIBS_PATH", "./forks/")

  defp mess_sources() do
    mess_sources(System.get_env("WITH_FORKS","1"))
    |> Enum.map(fn {k,v} -> {k, config_path(v)} end)
  end

  defp mess_sources("0"),  do: [git: "deps.git", hex: "deps.hex"]
  defp mess_sources(_),    do: [path: "deps.path", git: "deps.git", hex: "deps.hex"]

  def deps_to_clean() do
    deps(:data)
    |> deps_names()
  end

  def deps_to_update() do
    deps(:update)
    |> deps_names()
    |> IO.inspect(label: "Running Bonfire #{version()} with configuration from #{flavour_path()} in #{Mix.env()} environment. You can run `mix bonfire.deps.update` to update these extensions and dependencies")
  end

  def deps_to_localise() do
    deps(:test)
    |> Enum.map(&dep_name/1)
  end

  # Specifies which paths to include when running tests
  defp test_paths(), do: ["test" | Enum.flat_map(deps(:test), &dep_paths(&1, "test"))]

  # Specifies which paths to compile per environment
  defp elixirc_paths(:test), do: ["lib", "test/support" | Enum.flat_map(deps(:test), &dep_paths(&1, "test/support"))]
  defp elixirc_paths(_), do: ["lib"] ++ catalogues()

  defp include_dep?(:test, dep), do: String.starts_with?(dep_name(dep), @config[:test_deps_prefixes])

  defp include_dep?(:data, dep), do: String.starts_with?(dep_name(dep), @config[:data_deps_prefixes])

  defp include_dep?(:update, dep) when is_tuple(dep), do: unpinned_git_dep?(dep)

  defp unpinned_git_dep?(dep) do
    spec = elem(dep, 1)
    is_list(spec) && spec[:git] && !spec[:commit]
  end

  defp dep_name(dep) when is_tuple(dep), do: elem(dep, 0) |> dep_name()
  defp dep_name(dep) when is_atom(dep), do: Atom.to_string(dep)
  defp dep_name(dep) when is_binary(dep), do: dep

  def deps_names(deps) do
      deps
      |> Enum.map(&dep_name/1)
      |> Enum.join(" ")
  end

  defp dep_path(dep) when is_binary(dep) do
    path_if_exists(Mix.Project.deps_path() <> "/" <> dep |> Path.relative_to(File.cwd!))
      || path_if_exists(forks_path()<>dep)
      || "."
  end

  defp dep_path(dep) do
    spec = elem(dep, 1)

    path = if is_list(spec) && spec[:path],
      do: spec[:path],
      else: Mix.Project.deps_path() <> "/" <> dep_name(dep) |> Path.relative_to(File.cwd!)

    path_if_exists(path)
  end

  defp path_if_exists(path), do: if File.exists?(path), do: path

  defp dep_paths(dep, extra) when is_list(extra), do: Enum.flat_map(extra, &dep_paths(dep, &1))
  defp dep_paths(dep, extra) when is_binary(extra) do
    dep_path = dep_path(dep)
    if dep_path do
      path = Path.join(dep_path, extra) |> path_if_exists()
      if path, do: [path], else: []
    else
      []
    end
  end

  def version do
    @config[:version]
      |> String.split("-", parts: 2)
      |> List.insert_at(1, flavour())
      |> Enum.join("-")
  end

end
