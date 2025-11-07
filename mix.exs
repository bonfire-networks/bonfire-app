Code.eval_file("lib/mix/mess.exs")
Code.eval_file("lib/mix/mixer.ex")

defmodule Bonfire.Umbrella.MixProject do
  use Mix.Project
  alias Bonfire.Mixer

  base_flavour = "ember"
  base_flavour_atom = String.to_atom(base_flavour)
  default_flavour = "social"
  flavour = System.get_env("FLAVOUR") || default_flavour
  flavour_atom = String.to_atom(flavour)

  yes? = ~w(true yes 1)
  no? = ~w(false no 0)

  # we only optionally behave as an umbrella im dev/test env
  use_local_forks? = System.get_env("WITH_FORKS", "1") in yes?
  include_git_deps? = System.get_env("WITH_GIT_DEPS", "1") in yes?
  ext_forks_path = Mixer.forks_path()

  base_flavour_local? = File.exists?("#{ext_forks_path}/#{base_flavour}")
  flavour_local? = File.exists?("#{ext_forks_path}/#{flavour}")

  use_umbrella? =
    Mix.env() == :dev and use_local_forks? and System.get_env("AS_UMBRELLA") in yes?

  @umbrella_path if use_umbrella?, do: ext_forks_path, else: nil

  if use_umbrella?, do: IO.puts("NOTE: Running as umbrella...")

  # including it by default breaks Dockerfile.release but not including it like this breaks CI...
  main_deps =
    if include_git_deps? do
      [
        if(base_flavour_local? and use_local_forks?,
          do:
            {base_flavour_atom,
             path: "#{ext_forks_path}/#{base_flavour}",
             from_umbrella: use_umbrella?,
             override: true},
          else:
            {base_flavour_atom,
             git: "https://github.com/bonfire-networks/#{base_flavour}", override: true}
        )
      ] ++
        if flavour != default_flavour do
          [
            if(flavour_local? and use_local_forks?,
              do:
                {flavour_atom,
                 path: "#{ext_forks_path}/#{flavour}",
                 from_umbrella: use_umbrella?,
                 override: true},
              else:
                {flavour_atom,
                 git: "https://github.com/bonfire-networks/#{flavour}", override: true}
            )
          ]
        else
          []
        end
    else
      []
    end

  maybe_api_deps =
    if(System.get_env("WITH_API_GRAPHQL") not in no?,
      do: [
        {:absinthe, "~> 1.7"},
        {:bonfire_api_graphql, git: "https://github.com/bonfire-networks/bonfire_api_graphql"},
        {:absinthe_client, git: "https://github.com/bonfire-networks/absinthe_client"}
        # {:apical, git: "https://github.com/bonfire-networks/apical"}
      ],
      else: []
    )

  # TODO: move to bonfire_files?
  with_vix = System.get_env("WITH_IMAGE_VIX")

  maybe_image_vix =
    if(with_vix && with_vix not in no?,
      do: [
        {:image, "~> 0.62", runtime: true, override: true},
        {:evision, "~> 0.2", runtime: true, override: true}
      ],
      else: []
    )

  # TODO: move to ember?
  with_ai = System.get_env("WITH_AI")

  maybe_ai_deps =
    if(with_ai && with_ai not in no?,
      do: [
        {:bumblebee, "~> 0.6.3"},
        {:axon, "~> 0.7.0", override: true},
        {:table_rex, "~> 4.0.0", override: true},
        # {:nx, "~> 0.9.0"},
        # {:exla, "~> 0.9.1"},
        # temp workaround: https://github.com/elixir-nx/nx/issues/1599
        {:exla, github: "elixir-nx/nx", sparse: "exla", override: true},
        {:nx, github: "elixir-nx/nx", sparse: "nx", override: true}
      ],
      else: []
    )

  with_xmpp = System.get_env("WITH_XMPP")

  maybe_xmpp_deps =
    if(with_xmpp && with_xmpp not in no?,
      do: [
        {:xmpp, "~> 1.11"},
        {:ejabberd, "~> 25.8"},
        {
          :bonfire_xmpp,
          path: "extensions/bonfire_xmpp"
          # git: "https://github.com/bonfire-networks/jungle"
        }
      ],
      else: []
    )

  # NOTE: exqlite not working in CI
  maybe_non_ci_deps =
    if(System.get_env("CI") not in yes?,
      do: [
        {
          :archeometer,
          "~> 0.5.0",
          # git: "https://gitlab.com/mayel/archeometer",
          only: [:dev], runtime: false
        },
        {:ex_unit_notifier, "~> 1.0", only: :test}
      ],
      else: []
    )

  extra_deps =
    main_deps ++
      maybe_api_deps ++
      maybe_image_vix ++
      maybe_ai_deps ++
      maybe_xmpp_deps ++
      maybe_non_ci_deps ++
      [
        # TODO: move most of these deps to ember or elsewhere?
        {
          :mess,
          # path: "forks/mess",
          git: "https://github.com/bonfire-networks/mess", only: [:dev, :test], override: true
        },
        {:jungle,
         git: "https://github.com/bonfire-networks/jungle", only: [:dev, :test], override: true},
        # {:ex_aws, git: "https://github.com/bonfire-networks/ex_aws", override: true},

        # compilation
        # {:tria, github: "hissssst/tria"},

        ## password hashing - builtin vs nif
        {:pbkdf2_elixir, "~> 2.0", only: [:dev, :test]},
        {:argon2_elixir, "~> 4.0", only: [:prod]},

        ## dev conveniences
        {
          :tidewave,
          "~> 0.4",
          # git: "https://github.com/tidewave-ai/tidewave_phoenix/",
          only: :dev
        },
        {:live_debugger, "~> 0.3.2", only: :dev},
        {:phoenix_live_reload, "~> 1.3", only: :dev, targets: [:host], override: true},
        # {:exsync, git: "https://github.com/falood/exsync", only: :dev},
        # {:mix_unused, "~> 0.4", only: :dev}, # find unused public functions
        {:ex_doc, "~> 0.38.0", runtime: false},
        {:ecto_erd, "~> 0.4", only: :dev},
        {:excellent_migrations, "~> 0.1", only: [:dev, :test], runtime: false},
        # {:ecto_dev_logger, "~> 0.7", only: :dev},
        # flame graphs in live_dashboard
        # {:flame_on, "~> 0.7"},
        {:pseudo_gettext, git: "https://github.com/tmbb/pseudo_gettext", only: :dev},
        {:periscope, "~> 0.4", only: :dev},
        # {:changelog, "~> 0.1", only: [:dev, :test], runtime: false}, # retrieve changelogs of latest dependency versions
        # changelog generation
        {:versioce, "~> 2.0.0", only: :dev},
        # needed for changelog generation
        {:git_cli, "~> 0.3.0", only: :dev},
        # {:recode, "~> 0.4", only: :dev},
        # API client needed for changelog generation
        {:neuron, "~> 5.0", only: :dev, override: true},
        # note: cannot use only: dev
        # {:phoenix_profiler, "~> 0.2.0"},
        # "~> 0.1.0", path: "forks/one_plus_n_detector",
        # {:one_plus_n_detector, git: "https://github.com/bonfire-networks/one_plus_n_detector", only: :dev},
        {:observer_cli, "~> 1.7", only: [:dev, :test]},
        {:map_diff, "~> 1.3", only: [:dev, :test]},

        # for extension install + mix tasks that do patching
        {
          :igniter,
          "~> 0.6.7",
          # path: "forks/igniter",
          # git: "https://github.com/ash-project/igniter",
          # only: [:dev, :test],
          override: true
        },

        # tests
        # {:floki, "~> 0.37.1", only: [:dev, :test]},
        # {:pages, "~> 0.12", only: :test}, # extends Floki for testing
        {
          :phoenix_test,
          "~> 0.7",
          # git: "https://github.com/germsvel/phoenix_test",
          only: :test, runtime: false
        },
        # {:lazy_html, ">= 0.1.0", only: :test},
        {:patch, "~> 0.15.0"},
        {:mock, "~> 0.3", only: :test},
        {:mox, "~> 1.0", only: [:dev, :test]},
        {:bypass, "~> 2.1", only: :test},
        {:ex_machina, "~> 2.7", only: [:dev, :test]},
        {:zest, "~> 0.1.0"},
        {:grumble, "~> 0.1.3", only: [:test], override: true},
        {:mix_test_watch, "~> 1.1", only: :test, runtime: false, override: true},
        {:mix_test_interactive, "~> 5.0", only: :test, runtime: false},
        {:ex_unit_summary, "~> 0.1.0", only: :test},
        {:wallaby, "~> 0.30", runtime: false, only: :test},
        #  for phoenix_live_reload/credo compat with archeometer
        {:file_system, "~> 1.0", override: true},
        # "~> 1.6.7", # version used by archeometer
        {:credo, "~> 1.7.10", only: [:dev, :test], override: true},
        # NOTE: not compatible with the credo version needed for archeometer
        {:mneme, ">= 0.10.0", only: [:dev, :test]},
        # used in unfurl
        # {:bypass, "~> 2.1", only: :test},
        {:assert_value, ">= 0.0.0", only: [:dev, :test]},
        {:repatch, "~> 1.5", only: :test},

        # Benchmarking utilities
        {:benchee, "~> 1.1", override: true},
        {:benchee_html, "~> 1.0", only: [:dev, :test]},
        # for Telemetry store
        {:circular_buffer, "~> 0.4", only: :dev},
        # {:chaperon, "~> 0.3.1", only: [:dev, :test]},

        # logging
        {
          :sentry,
          "~> 11.0",
          # git: "https://github.com/getsentry/sentry-elixir",
          only: [:dev, :prod], override: true
        },

        # list dependencies & licenses
        # {
        #   :licensir,
        #   only: :dev,
        #   runtime: false,
        #   git: "https://github.com/bonfire-networks/licensir",
        #   # path: "./forks/licensir"
        # },

        # security auditing
        # {:mix_audit, "~> 0.1", only: [:dev], runtime: false}
        {:sobelow, "~> 0.14.0", only: :dev}
      ]

  @mess_opts [
    flavour: flavour_atom,
    config_dir: "config/",
    base_flavour: base_flavour_atom,
    use_local_forks?: use_local_forks?,
    use_umbrella?: use_umbrella?,
    umbrella_root?: use_local_forks?,
    umbrella_path: @umbrella_path
  ]

  deps =
    Mixer.mess_sources(flavour)
    |> Mixer.log(label: "mess sources", limit: :infinity)
    |> Mess.deps(
      extra_deps,
      @mess_opts
    )
    |> Mixer.log(label: "top level deps", limit: :infinity)

  extra_release_apps =
    deps
    |> Enum.filter(fn
      {_dep, opts} when is_list(opts) ->
        opts[:runtime] == false and
          (is_nil(opts[:only]) or :prod in List.wrap(opts[:only]))

      {_dep, _, opts} ->
        opts[:runtime] == false and
          (is_nil(opts[:only]) or :prod in List.wrap(opts[:only]))

      _ ->
        false
    end)
    # Mixer.other_flavour_sources()
    |> Mixer.deps_names_list()
    |> Enum.reject(&(&1 in [:bonfire, :ex_doc]))
    # ++ [:phoenix_live_head, :phoenix_live_favicon] # to avoid error with ex_doc being set to :load
    |> Enum.map(&{&1, :load})
    |> Mixer.log("disabled extensions to still include in release")

  test_federation = [
    "activity_pub",
    "bonfire_federate_"
  ]

  test_backend = [
    "bonfire_",
    "needle",
    # "paginator",
    "ecto_shorts",
    "ecto_sparkles",
    "arrows",
    "linkify",
    "faviconic"
    # "paper_trail"
  ]

  test_ui = [
    "bonfire_ui_",
    "bonfire_boundaries",
    "bonfire_search",
    "bonfire_geolocate",
    "bonfire_files",
    "bonfire_invite_links"
  ]

  # TODO: put these in ENV or an external writeable config file similar to deps.*
  @config [
    # note that the flavour will automatically be added where the dash appears
    version: "1.0.0",
    elixir: ">= #{System.get_env("ELIXIR_VERSION", "1.13.4")}",
    flavour: flavour,
    default_flavour: default_flavour,
    logo: "assets/static/images/bonfire-icon.png",
    guides:
      [
        # "docs/introduction.md",
        "README.md"
        # "docs/HACKING.md",
        # "docs/DEPLOY.md",
        # "docs/CHANGELOG.md"
        # "docs/CHANGELOG-autogenerated.md",
      ] ++
        Path.wildcard("docs/*.md") ++
        Path.wildcard("LICENSES/*.md") ++
        Path.wildcard("docs/user_guides/*.md") ++
        Path.wildcard("docs/topics/*.md") ++
        Path.wildcard("docs/building/*.md"),
    deps_prefixes: [
      docs: [
        "bonfire",
        "needle",
        "pride",
        "paginator",
        "ecto_shorts",
        "ecto_sparkles",
        "absinthe_client",
        "activity_pub",
        "http_signatures",
        "arrows",
        "ecto_materialized_path",
        "exto",
        "untangle",
        # "grumble",
        "linkify",
        "verbs",
        "voodoo",
        "entrepot",
        # "waffle",
        "unfurl",
        # "zest",
        "iconify",
        "faviconic"
        # "paper_trail"
      ],
      test_federation: test_federation,
      test_backend: test_backend,
      test_ui: test_ui,
      test: test_backend ++ test_federation ++ test_ui,
      data: [
        "bonfire_data_",
        "bonfire_data_edges",
        "needle",
        "bonfire_boundaries",
        "bonfire_tag",
        "bonfire_classify",
        "bonfire_geolocate",
        "bonfire_quantify",
        "bonfire_valueflows",
        "article_"
      ],
      api: [
        "bonfire_api_graphql",
        "bonfire_me",
        "bonfire_social",
        "bonfire_tag",
        "bonfire_classify",
        "bonfire_geolocate",
        "bonfire_quantify",
        "bonfire_valueflows"
      ],
      required: [
        "bonfire_boundaries",
        "bonfire_social",
        "bonfire_me",
        "bonfire_ecto",
        "bonfire_epics",
        "bonfire_common",
        "bonfire_fail",
        "bonfire_ui_common",
        "bonfire_ui_me",
        "bonfire_ui_social",
        "bonfire_ui_boundaries"
      ],
      localise: ["bonfire"],
      localise_self: [
        # FIXME: should extract to root app, not activity_pub like it's doing (for whatever reason)
        "activity_pub"
      ],
      update: [
        "bonfire_",
        "ember",
        "social",
        "community",
        "coordination",
        "cooperation",
        "upcycle",
        "open_science",
        "federated_archives",
        "linkify",
        "unfurl",
        "untangle",
        "iconify_ex",
        "boruta",
        "ecto_shorts",
        "ecto_materialized_path",
        "phoenix_gon",
        "http_signatures",
        "forecastr"
      ]
    ],
    deps: deps,
    disabled_extensions: extra_release_apps
    # |> Mixer.log(limit: :infinity)
  ]

  @umbrella_apps if use_umbrella?, do: Mess.read_umbrella_names(@mess_opts)

  def config, do: @config
  def deps, do: config()[:deps]

  def project_info do
    [
      name: "Bonfire",
      app: :bonfire,
      version: Mixer.version(config()),
      apps: @umbrella_apps,
      apps_path: @umbrella_path,
      elixir: config()[:elixir],
      elixirc_options: [debug_info: true, docs: true],
      elixirc_paths: Mixer.elixirc_paths(config(), Mix.env()),
      test_paths: Mixer.test_paths(config()),
      # test_deps: Mixer.deps(config(), :test) |> Mixer.log(),
      required_deps: config()[:deps_prefixes][:required],
      # consolidate_protocols: false, # for Tria
      compilers: Mixer.compilers(Mix.env()),
      listeners: [Phoenix.CodeReloader],
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      multirepo_deps: Mixer.deps(config(), :bonfire),
      in_multirepo_fn: &Mixer.in_multirepo?/1,
      multirepo_recompile_fn: &Mixer.deps_recompile/0,
      config_path: "config/config.exs",
      releases: [
        bonfire: [
          runtime_config_path: Mixer.config_path("runtime.exs"),
          # should BEAM files should have their debug information, documentation chunks, and other non-essential metadata?
          strip_beams: false,
          applications:
            [
              bonfire: :permanent
              # if observability fails it shouldn’t take your app down with it - FIXME: getting this in CI: Could not find application :opentelemetry
              # opentelemetry: :temporary
              # opentelemetry_exporter: :temporary,
            ] ++ config()[:disabled_extensions]
        ]
      ],
      sources_url: "https://github.com/bonfire-networks",
      source_url: "https://github.com/bonfire-networks/bonfire-app",
      homepage_url: "https://bonfirenetworks.org",
      preferred_cli_env: ["mneme.test": :test, "mneme.watch": :test]
    ]
  end

  def docs do
    [
      # The first page to display from the docs
      main: "readme",
      output: "docs/exdoc",
      logo: config()[:logo],
      source_url_pattern: &Mixer.source_url_pattern/2,
      extras: Mixer.extra_guide_paths(config()),
      source_beam: Mixer.docs_beam_paths(config()),
      deps: Mixer.doc_dep_urls(config()),
      assets: %{
        "docs/assets" => "assets",
        "docs/building/assets" => "assets",
        "docs/user_guide/assets" => "assets",
        "docs/topics/assets" => "assets"
      },
      # Note: first match wins
      groups_for_extras: [
        "Getting Started": [
          "docs/HACKING.md",
          "docs/SETUP.md",
          "docs/DEPLOY.md"
        ],
        "Building on Bonfire": Path.wildcard("docs/building/*.md"),
        "User guides": Path.wildcard("docs/user_guides/*.md"),
        Licenses:
          Path.wildcard("LICENSES/*") ++
            Path.wildcard("{extensions,deps,forks}/*/LICENSES/*") ++
            Path.wildcard("{extensions,deps,forks}/*/LICENSE"),
        Concepts:
          Path.wildcard("docs/topics/*.md") ++
            Path.wildcard("{extensions,deps,forks}/*/docs/*.md") ++
            Path.wildcard(
              "{deps,forks,extensions}/{needle,bonfire_boundaries,bonfire_api_graphql,bonfire_mailer}/*.md"
              # "{forks,extensions}/{needle,bonfire_boundaries,bonfire_api_graphql,bonfire_mailer}/*.md"
            ),
        "Data schemas": Path.wildcard("{extensions,deps,forks}/bonfire_data_*/*.md"),
        "UI extensions": Path.wildcard("{extensions,deps,forks}/bonfire_ui_*/*.md"),
        "Bonfire utilities":
          [
            "bonfire_api_graphql",
            "bonfire_boundaries",
            "bonfire_common",
            "bonfire_ecto",
            "bonfire_epics",
            "bonfire_fail",
            "bonfire_files",
            "bonfire_mailer"
          ]
          |> Enum.flat_map(&Path.wildcard("{extensions,deps,forks}/#{&1}/*.md")),
        "Feature extensions": Path.wildcard("{extensions,deps,forks}/bonfire_*/*.md"),
        "Other utilities": Path.wildcard("{extensions,deps,forks}/*/*.md"),
        Dependencies: Path.wildcard("docs/DEPENDENCIES/*.md")
      ],
      groups_for_modules: [
        # "Concepts": Bonfire.Boundaries,
        "Data schemas": ~r/^Bonfire.Data.?/,
        "UI extensions": ~r/^Bonfire.UI.?/,
        "Bonfire utilities": [
          ~r/^Bonfire.API?/,
          ~r/^Bonfire.GraphQL?/,
          ~r/^Bonfire.Web?/,
          ~r/^Bonfire.Boundaries?/,
          ~r/^Bonfire.Common?/,
          ~r/^Bonfire.Ecto?/,
          ~r/^Bonfire.Epics?/,
          ~r/^Bonfire.Fail?/,
          ~r/^Bonfire.Files?/,
          ~r/^Bonfire.Mailer?/,
          ~r/^Needle?/,
          ~r/^Exto?/,
          ~r/^Arrows?/,
          ~r/^AnimalAvatarGenerator?/,
          ~r/^EctoSparkles?/,
          ~r/^Releaser?/,
          ~r/^Voodoo?/,
          ~r/^Untangle?/
        ],
        "Feature extensions": [~r/^Bonfire.?/, ~r/^ValueFlows.?/],
        Federation: [
          ~r/^ActivityPub.?/,
          ~r/^ActivityPub.?/,
          ~r/^Nodeinfo.?/,
          ~r/^NodeinfoWeb.?/
        ],
        Icons: ~r/^Iconify.?/,
        Utilities: ~r/.?/
      ],
      nest_modules_by_prefix: [
        Bonfire.Data,
        # Bonfire.UI,
        Bonfire,
        ActivityPub,
        ActivityPub.Web,
        # ValueFlows,
        Iconify
      ]
    ]
  end

  def project do
    project_info() ++
      [
        docs: docs()
      ]
  end

  def application do
    # Bonfire.MixProject.application()
    [
      mod: {Bonfire.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  def cli do
    [
      default_task: "phx.server"
      # preferred_envs: [docs: :docs]
    ]
  end

  defp aliases do
    [
      "hex.setup": ["local.hex --force"],
      "rebar.setup": ["local.rebar --force"],
      hex_setup: [
        "hex.setup",
        "rebar.setup"
      ],
      "bonfire.seeds": [
        # "phil_columns.seed",
      ],
      # FIXME: this does not update transitive deps
      "bonfire.deps.update": ["deps.update " <> Mixer.deps_to_update(config())],
      "bonfire.deps.clean": [
        "deps.clean " <> Mixer.deps_to_clean(config(), :localise) <> " --build"
      ],
      "bonfire.deps.clean.data": [
        "deps.clean " <> Mixer.deps_to_clean(config(), :data) <> " --build"
      ],
      "bonfire.deps.clean.api": [
        "deps.clean " <> Mixer.deps_to_clean(config(), :api) <> " --build"
      ],
      "bonfire.deps.compile": [
        "deps.compile " <> Mixer.deps_to_update(config())
      ],
      "ecto.seeds": [
        "run priv/repo/seeds.exs"
      ],
      updates: ["deps.get", "bonfire.deps.update"],
      upgrade: ["updates", "ecto.migrate"],
      "ecto.setup": ["ecto.create", "ecto.migrate"],
      "ecto.migrate": ["bonfire.seeds"],
      "ecto.reset": ["ecto.drop --force", "ecto.setup"],
      "test.with-db": ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "format.assets": [
        "format",
        "cmd --cd assets/ yarn format.js",
        "cmd --cd assets/ yarn format.css"
      ],
      "format.all": [
        "format",
        "format.assets"
      ],
      sobelow: ["cmd mix sobelow"]
    ]
  end
end
