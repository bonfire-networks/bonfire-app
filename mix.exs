defmodule VoxPublica.MixProject do
  use Mix.Project

  def project do
    [
      app: :vox_publica,
      version: "0.1.0",
      elixir: "~> 1.10",
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

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

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

      {:pointers_ulid, "~> 0.2"},
      # {:pointers_ulid, path: "../pointers_ulid", override: true},

      # {:pointers, "~> 0.5.1"},
      # {:pointers, git: "https://github.com/commonspub/pointers", branch: "main"},
      {:pointers, path: "../pointers", override: true},

      {:flexto, "~> 0.2.1", override: true},
      # {:flexto, path: "../flexto", override: true},

      {:cpub_accounts, "~> 0.1"},
      # {:cpub_accounts, git: "https://github.com/commonspub/cpub_accounts", branch: "main"},
      # {:cpub_accounts, path: "../cpub_accounts", override: true},

      {:cpub_blocks, "~> 0.1"},
      # {:cpub_blocks, git: "https://github.com/commonspub/cpub_blocks", branch: "main"},
      # {:cpub_blocks, path: "../cpub_blocks", override: true},

      # {:cpub_bookmarks, git: "https://github.com/commonspub/cpub_bookmarks", branch: "main"},
      # # {:cpub_bookmarks, path: "../cpub_bookmarks", override: true},

      {:cpub_characters, "~> 0.1"},
      # {:cpub_characters, git: "https://github.com/commonspub/cpub_characters", branch: "main"},
      # {:cpub_characters, path: "../cpub_characters", override: true},

      # {:cpub_circles, "~> 0.1"},
      # {:cpub_circles, git: "https://github.com/commonspub/cpub_circles", branch: "main"},
      # {:cpub_circles, path: "../cpub_circles", override: true},

      # {:cpub_comments, "~> 0.1"},
      # {:cpub_comments, git: "https://github.com/commonspub/cpub_comments", branch: "main"},
      # {:cpub_comments, path: "../cpub_comments", override: true},

      # {:cpub_communities, "~> 0.1"},
      # {:cpub_communities, git: "https://github.com/commonspub/cpub_communities", branch: "main"},
      # {:cpub_communities, path: "../cpub_communities", override: true},

      {:cpub_emails, "~> 0.1"},
      # {:cpub_emails, git: "https://github.com/commonspub/cpub_emails", branch: "main"},
      # {:cpub_emails, path: "../cpub_emails", override: true},

      {:cpub_local_auth, "~> 0.1"},
      # {:cpub_local_auth, git: "https://github.com/commonspub/cpub_local_auth", branch: "main"},
      # {:cpub_local_auth, path: "../cpub_local_auth", override: true},

      {:cpub_profiles, "~> 0.1"},
      # {:cpub_profiles, git: "https://github.com/commonspub/cpub_profiles", branch: "main"},
      # {:cpub_profiles, path: "../cpub_profiles", override: true},

      {:cpub_users, "~> 0.1"},
      # {:cpub_users, git: "https://github.com/commonspub/cpub_users", branch: "main"},
      # {:cpub_users, path: "../cpub_users", override: true},

      {:activity_pub, git: "https://gitlab.com/CommonsPub/activitypub.git", branch: :develop},
      {:oban, "~> 2.0.0"},

      # {:fast_sanitize, "~> 0.2.2"}, # html sanitisation

      {:faker, "~> 0.14"}, # fake data generation

      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:dbg, "~> 1.0", only: [:dev, :test]},
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
