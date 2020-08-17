defmodule VoxPublica.MixProject do
  use Mix.Project

  def project do
    [
      app: :vox_publica,
      version: "0.1.0",
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  def application do
    [
      mod: {VoxPublica.Application, []},
      extra_applications: [:logger, :runtime_tools, :os_mon]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix_live_view, "~> 0.14"},
      {:phoenix_html, "~> 2.11"},
      {:phoenix_live_dashboard, "~> 0.2.0"},
      {:plug_cowboy, "~> 2.0"},
      {:phoenix, "~> 1.5.3"},
      {:phoenix_ecto, "~> 4.1"},
      {:ecto_sql, "~> 3.4"},
      {:postgrex, ">= 0.0.0"},
      {:telemetry_metrics, "~> 0.4"},
      {:telemetry_poller, "~> 0.4"},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:cloak_ecto, "~> 1.0"},

      {:pointers_ulid, "~> 0.2"},
      # {:pointers_ulid, path: "../pointers_ulid", override: true},

      {:pointers, "~> 0.3"},
      # {:pointers, path: "../pointers", override: true},

      {:flexto, "~> 0.2"},
      # {:flexto, path: "../flexto", override: true},

      # {:cpub_core, "~> 0.1"},
      # {:cpub_core, path: "../cpub_core"},
      # {:pager, path: "../pager"},
      # {:resolute, path: "../resolute"},
      {:activity_pub, git: "https://gitlab.com/CommonsPub/activitypub.git", branch: :develop},

      {:phoenix_live_reload, "~> 1.2", only: :dev},

      {:floki, ">= 0.0.0", only: :test},
    ]
  end

  defp aliases do
    [
      "js.deps.get": ["cmd npm install --prefix assets"],
      "ecto.seeds": ["run priv/repo/seeds.exs"],
      setup: ["deps.get", "ecto.setup", "js.deps.get"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "ecto.seeds"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"]
    ]
  end
end
