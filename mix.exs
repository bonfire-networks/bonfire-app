Code.eval_file("mess.exs")
defmodule Bonfire.MixProject do

  use Mix.Project

  @bonfire_test_deps [
    "pointers",
    "bonfire_common",
    "bonfire_me",
    "bonfire_social",
    "bonfire_boundaries",
    "bonfire_ui_social",
    # "bonfire_website",
    "bonfire_tag",
    "bonfire_federate_activitypub",

    "bonfire_geolocate",
    "bonfire_quantify",
    "bonfire_valueflows",
    "bonfire_ui_valueflows",
    "bonfire_ui_reflow",
    "bonfire_breadpub",
    "bonfire_classify",
    "bonfire_valueflows_observe",
  ]

  @bonfire_deps @bonfire_test_deps ++ [
    "activity_pub",
    "query_elf",

    "bonfire_data_access_control",
    "bonfire_data_identity",
    "bonfire_data_social",
    "bonfire_data_activity_pub",
    "bonfire_mailer",
    "bonfire_fail",
    "bonfire_data_shared_user",
    "bonfire_search",
    # "bonfire_recyclapp",
    "bonfire_api_graphql",
    # "bonfire_taxonomy_seeder",
  ]

  def project do
    [
      app: :bonfire,
      version: "0.1.0-alpha.27",
      elixir: "~> 1.11",
      elixirc_paths: elixirc_paths(Mix.env()),
      test_paths: ["test"] ++ existing_deps_paths(@bonfire_test_deps, "test"),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end


  defp deps() do
    Mess.deps([
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
      # list dependencies & licenses
      {:licensir, only: :dev, runtime: false,
        git: "https://github.com/mayel/licensir", branch: "pr",
        # path: "./forks/licensir"
      },
      {:surface, "~> 0.3.0"},
      # Testing a component library for liveview
      # {:surface_catalogue, "~> 0.0.7", only: :dev},

      # security auditing
      # {:mix_audit, "~> 0.1", only: [:dev], runtime: false}
      {:sobelow, "~> 0.8", only: :dev}
    ])
    # |> IO.inspect()
  end


  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"] ++ existing_deps_paths(@bonfire_test_deps, "test/support")
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
      "js.deps.get": [
        "cmd npm install --prefix assets",
        # "cmd npm install --prefix "<>existing_dep_path("bonfire_geolocate")<>"/assets"
      ],
      "js.deps.update": ["cmd npm update --prefix assets"],
      "ecto.seeds": [
        # "phil_columns.seed",
        "run priv/repo/seeds.exs"
        ],
      "bonfire.deps.update": ["deps.update #{@bonfire_deps_str}"],
      "bonfire.deps.clean": ["deps.clean #{@bonfire_deps_str} --build"],
      "bonfire.deps": ["bonfire.deps.update", "bonfire.deps.clean"],
      setup: ["hex.setup", "rebar.setup", "deps.get", "bonfire.deps.clean", "ecto.setup", "js.deps.get"],
      updates: ["deps.get", "bonfire.deps", "js.deps.get"],
      upgrade: ["updates", "ecto.migrate"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "ecto.seeds"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "ecto.seeds", "test"]
    ]
  end

  defp dep_path(dep) do
    # use locally cloned repo if path defined and active, otherwise stick to code obtained by mix deps.get
    #
    # NOTE: to_atom (instead of to_existing_atom) is safe because its used at build time, the code might fail
    # NOTE: otherwise because of the atom never existing as part of compilation
    deps()[String.to_atom(dep)][:path] || "./deps/"<>dep
  rescue
    CaseClauseError -> "./deps/"<>dep # FIXME
  end

  # defp existing_dep_path(dep) do
  #   dep = dep_path(dep)

  #   if File.exists?(dep), do: dep, else: "."
  # end

  defp existing_deps_paths(list, path) do
    Enum.map(list, fn dep -> dep_path(dep) <>"/"<>path end)
    |> existing_paths()
    # |> IO.inspect()
  end

  defp existing_paths(list) do
    Enum.filter(list, &File.exists?(&1))
  end

end
