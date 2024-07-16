Code.eval_file("lib/mix/mess.exs")
Code.eval_file("lib/mix/mixer.ex")

defmodule Bonfire.Umbrella.MixProject do
  use Mix.Project
  alias Bonfire.Mixer

  @default_flavour "classic"
  @flavour System.get_env("FLAVOUR") || @default_flavour

  # we only behave as an umbrella im dev/test env
  @use_local_forks System.get_env("WITH_FORKS", "1") == "1"
  ext_forks_path = Mixer.forks_path()

  @use_umbrella? Mix.env() == :dev and @use_local_forks and System.get_env("AS_UMBRELLA") == "1" and
                   File.exists?("#{ext_forks_path}/bonfire")
  @umbrella_path if @use_umbrella?, do: ext_forks_path, else: nil

  if @use_umbrella?, do: IO.puts("NOTE: Running as umbrella...")

  # including it by default breaks Dockerfile.release but not including it like this breaks CI...
  @main_deps if(System.get_env("WITH_GIT_DEPS") == "0",
               do: [{:bonfire, git: "https://github.com/bonfire-networks/bonfire"}],
               else: []
             )
  @maybe_api_deps if(System.get_env("WITH_API_GRAPHQL") == "yes",
                    do: [
                      {:absinthe, "~> 1.7"},
                      {:bonfire_api_graphql,
                       git: "https://github.com/bonfire-networks/bonfire_api_graphql"},
                      {:absinthe_client,
                       git: "https://github.com/bonfire-networks/absinthe_client"}
                    ],
                    else: []
                  )

  @maybe_image_vix if(System.get_env("ENABLE_IMAGE_VIX") != "0",
                     do: [
                       {:image, "~> 0.37", runtime: true, override: true},
                       {:evision, "~> 0.1", runtime: true, override: true}
                     ],
                     else: []
                   )

  @extra_deps @main_deps ++
                @maybe_api_deps ++
                @maybe_image_vix ++
                [
                  {:ex_aws, git: "https://github.com/bonfire-networks/ex_aws", override: true},
                  # compilation
                  # {:tria, github: "hissssst/tria"},

                  ## password hashing - builtin vs nif
                  {:pbkdf2_elixir, "~> 2.0", only: [:dev, :test]},
                  {:argon2_elixir, "~> 4.0", only: [:prod]},

                  ## dev conveniences
                  {:phoenix_live_reload, "~> 1.3", only: :dev, targets: [:host], override: true},
                  #
                  # {:exsync, git: "https://github.com/falood/exsync", only: :dev},
                  # {:mix_unused, "~> 0.4", only: :dev}, # find unused public functions
                  {:ex_doc, "~> 0.34.0", only: [:dev, :test], runtime: false},
                  {:ecto_erd, "~> 0.4", only: :dev},
                  {:excellent_migrations, "~> 0.1", only: [:dev, :test], runtime: false},
                  # {:ecto_dev_logger, "~> 0.7", only: :dev},
                  # flame graphs in live_dashboard
                  # {:flame_on, "~> 0.5", only: :dev},
                  {:pseudo_gettext, git: "https://github.com/tmbb/pseudo_gettext", only: :dev},
                  {:periscope, "~> 0.4", only: :dev},
                  # {:changelog, "~> 0.1", only: [:dev, :test], runtime: false}, # retrieve changelogs of latest dependency versions
                  # changelog generation
                  {:versioce, "~> 2.0.0", only: :dev},
                  # needed for changelog generation
                  {:git_cli, "~> 0.3.0", only: :dev},
                  # {:archeometer, git: "https://gitlab.com/mayel/archeometer", only: [:dev, :test]}, # "~> 0.1.0" # disabled because exqlite not working in CI
                  {:recode, "~> 0.4", only: :dev},
                  # API client needed for changelog generation
                  {:neuron, "~> 5.0", only: :dev, override: true},
                  # note: cannot use only: dev
                  # {:phoenix_profiler, "~> 0.2.0"},
                  # "~> 0.1.0", path: "forks/one_plus_n_detector",
                  # {:one_plus_n_detector, git: "https://github.com/bonfire-networks/one_plus_n_detector", only: :dev},
                  {:observer_cli, "~> 1.7", only: [:dev, :test]},

                  # tests
                  # {:floki, ">= 0.0.0", only: [:dev, :test]},
                  # {:pages, "~> 0.12", only: :test}, # extends Floki for testing
                  {
                    :phoenix_test,
                    "~> 0.3",
                    # git: "https://github.com/germsvel/phoenix_test",
                    only: :test, runtime: false
                  },
                  {:mock, "~> 0.3", only: :test},
                  {:mox, "~> 1.0", only: :test},
                  {:ex_machina, "~> 2.7", only: [:dev, :test]},
                  {:zest, "~> 0.1.0"},
                  {:grumble, "~> 0.1.3", only: [:test], override: true},
                  {:mix_test_watch, "~> 1.1", only: :test, runtime: false, override: true},
                  {:mix_test_interactive, "~> 2.0", only: :test, runtime: false},
                  {:ex_unit_summary, "~> 0.1.0", only: :test},
                  {:ex_unit_notifier, "~> 1.0", only: :test},
                  {:wallaby, "~> 0.30", runtime: false, only: :test},
                  {:credo, "~> 1.7.5", only: :test, override: true},
                  # used in furlex
                  # {:bypass, "~> 2.1", only: :test},
                  {:assert_value, ">= 0.0.0", only: [:dev, :test]},
                  {:mneme, ">= 0.0.0", only: [:dev, :test]},

                  # Benchmarking utilities
                  {:benchee, "~> 1.1", override: true},
                  {:benchee_html, "~> 1.0", only: [:dev, :test]},
                  # for Telemetry store
                  {:circular_buffer, "~> 0.4", only: :dev},
                  # {:chaperon, "~> 0.3.1", only: [:dev, :test]},

                  # logging
                  {:sentry, "~> 10.0", only: [:dev, :prod], override: true},

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
                  {:sobelow, "~> 0.12.1", only: :dev}
                ]

  @deps Mixer.mess_sources(@flavour)
        |> Mess.deps(@extra_deps,
          use_local_forks?: @use_local_forks,
          use_umbrella?: @use_umbrella?,
          umbrella_root?: @use_local_forks,
          umbrella_path: @umbrella_path
        )

  # |> Mixer.log(limit: :infinity)

  @extra_release_apps @deps
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
                      |> Enum.reject(&(&1 == :bonfire))
                      |> Enum.map(&{&1, :load})
                      |> Mixer.log("disabled extensions to still include in release")

  @test_federation [
    "activity_pub",
    "bonfire_federate_"
  ]
  @test_backend [
    "bonfire_",
    "needle",
    # "paginator",
    "ecto_shorts",
    "ecto_sparkles",
    "arrows",
    "linkify",
    "fetch_favicon"
    # "paper_trail"
  ]
  @test_ui [
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
    version: "0.9.10-beta.108",
    elixir: ">= #{System.get_env("ELIXIR_VERSION", "1.13.4")}",
    flavour: @flavour,
    default_flavour: @default_flavour,
    logo: "assets/static/images/bonfire-icon.png",
    guides: [
      # "docs/introduction.md",
      "README.md",
      "docs/HACKING.md",
      "docs/just-commands.md",
      "docs/DEPLOY.md",
      "docs/topics/ARCHITECTURE.md",
      "docs/topics/design_guidelines.md",
      "docs/topics/BONFIRE-FLAVOURED-ELIXIR.md",
      "docs/topics/DATABASE.md",
      "docs/topics/BOUNDARIES.md",
      "docs/topics/GRAPHQL.md",
      "docs/topics/MRF.md",
      "docs/CHANGELOG.md",
      # "docs/CHANGELOG-autogenerated.md",
      "docs/building/project-structure.md",
      "docs/building/what-is-flavour.md",
      "docs/building/extensions-overview.md",
      "docs/building/routing.md",
      "docs/building/create-a-new-extension.md",
      "docs/building/edit-an-existing-extension.md",
      "docs/building/create-a-new-page.md",
      "docs/building/add-a-new-widget.md",
      "docs/building/add-a-page-to-the-sidebar.md",
      "docs/building/add-an-extension-settings.md"
    ],
    deps_prefixes: [
      docs: [
        "bonfire",
        "needle",
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
        "grumble",
        "linkify",
        "verbs",
        "voodoo",
        "waffle",
        # "zest",
        "iconify",
        "fetch_favicon",
        "paper_trail"
      ],
      test_federation: @test_federation,
      test_backend: @test_backend,
      test_ui: @test_ui,
      test: @test_backend ++ @test_federation ++ @test_ui,
      data: [
        "bonfire_data_",
        "bonfire_data_edges",
        "needle",
        "bonfire_boundaries",
        "bonfire_tag",
        "bonfire_classify",
        "bonfire_geolocate",
        "bonfire_quantify",
        "bonfire_valueflows"
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
        "bonfire_ui_social"
      ],
      localise: ["bonfire"],
      localise_self: [
        # FIXME: should extract to root app, not activity_pub like it's doing (for whatever reason)
        "activity_pub"
      ]
    ],
    deps: @deps,
    disabled_extensions: @extra_release_apps
    # |> Mixer.log(limit: :infinity)
  ]

  def config, do: @config
  def deps, do: config()[:deps]

  def project do
    [
      name: "Bonfire",
      app: :bonfire_umbrella,
      apps_path: @umbrella_path,
      version: Mixer.version(config()),
      elixir: config()[:elixir],
      elixirc_options: [debug_info: true, docs: true],
      elixirc_paths: Mixer.elixirc_paths(config(), Mix.env()),
      test_paths: Mixer.test_paths(config()),
      # test_deps: Mixer.deps(config(), :test) |> Mixer.log(),
      required_deps: config()[:deps_prefixes][:required],
      # consolidate_protocols: false, # for Tria
      compilers: Mixer.compilers(Mix.env()),
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
              bonfire: :permanent,
              # if observability fails it shouldn’t take your app down with it
              opentelemetry_exporter: :temporary,
              opentelemetry: :temporary
            ] ++ config()[:disabled_extensions]
        ]
      ],
      sources_url: "https://github.com/bonfire-networks",
      source_url: "https://github.com/bonfire-networks/bonfire-app",
      homepage_url: "https://bonfirenetworks.org",
      docs: [
        # The first page to display from the docs
        main: "readme",
        logo: config()[:logo],
        output: "docs/exdoc",
        source_url_pattern: &Mixer.source_url_pattern/2,
        # extra pages to include
        extras: Mixer.readme_paths(config()),
        # extra apps to include in module docs
        source_beam: Mixer.docs_beam_paths(config()),
        # deps: Mixer.doc_dep_urls(config()),
        # Note: first match wins
        groups_for_extras: [
          "Getting Started": Path.wildcard("docs/*"),
          "Building on Bonfire": Path.wildcard("docs/building/*"),
          Concepts: Path.wildcard("docs/topics/*"),
          "Flavours of Bonfire": Path.wildcard("flavours/*/*"),
          "Data schemas": Path.wildcard("{extensions,deps,forks}/bonfire_data_*/*"),
          "UI extensions": Path.wildcard("{extensions,deps,forks}/bonfire_ui_*/*"),
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
            |> Enum.flat_map(&Path.wildcard("{extensions,deps,forks}/#{&1}/*")),
          "Feature extensions": Path.wildcard("{extensions,deps,forks}/bonfire_*/*"),
          "Other utilities": Path.wildcard("{extensions,deps,forks}/*/*"),
          Dependencies: Path.wildcard("docs/DEPENDENCIES/*")
        ],
        groups_for_modules: [
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
            ~r/^Needle?/
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
    ]
  end

  # def application, do: Bonfire.MixProject.application()

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
        "run #{Mixer.flavour_path(config())}/repo/seeds.exs"
      ],
      updates: ["deps.get", "bonfire.deps.update"],
      upgrade: ["updates", "ecto.migrate"],
      "ecto.setup": ["ecto.create", "ecto.migrate"],
      "ecto.migrate": ["bonfire.seeds"],
      "ecto.reset": ["ecto.drop --force", "ecto.setup"],
      "test.with-db": ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      sobelow: ["cmd mix sobelow"]
    ]
  end
end
