defmodule Bonfire.Application do
  @moduledoc false
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications

  use Application
  require Cachex.Spec
  alias Bonfire.Common.Config

  @sup_name Bonfire.Supervisor
  @top_otp_app Config.get!(:otp_app)
  @env Application.compile_env!(@top_otp_app, :env)
  @endpoint_module Application.compile_env!(@top_otp_app, :endpoint_module)
  @repo_module Application.compile_env(@top_otp_app, :repo_module)
  @project if Code.ensure_loaded?(Bonfire.Umbrella.MixProject),
             do: Bonfire.Umbrella.MixProject.project()
  @config if Code.ensure_loaded?(Bonfire.Umbrella.MixProject),
            do: Bonfire.Umbrella.MixProject.config(),
            else: Mix.Project.config()

  def default_cache_hours, do: Config.get(:default_cache_hours) || 3

  def apps_before,
    do:
      [
        # Metrics
        Bonfire.Common.Telemetry.Metrics,
        # Database
        @repo_module,
        # behaviour modules are loaded prepared as part of `Config.LoadExtensionsConfig` so no need to duplicate
        # Bonfire.Common.ExtensionBehaviour,
        # Config.LoadExtensionsConfig,
        # load instance Settings from DB into Config
        # needs to be after LoadInstanceConfig for seeds/fixtures
        if(@repo_module, do: EctoSparkles.AutoMigrator),
        Needle.Tables,
        Bonfire.Common.Settings.LoadInstanceConfig,
        # PubSub
        {Phoenix.PubSub, [name: Bonfire.Common.PubSub, adapter: Phoenix.PubSub.PG2]},
        Bonfire.UI.Common.Presence,
        # Persistent Data Services
        # Bonfire.Data.AccessControl.Accesses,
        ## these populate on first call, so no need to run on startup:
        # Bonfire.Common.ContextModule,
        # Bonfire.Common.QueryModule,
        # Bonfire.Federate.ActivityPub.FederationModules
        # {PhoenixProfiler, name: Bonfire.Web.Profiler},
        {Finch, name: Bonfire.Finch, pools: finch_pool_config()},
        %{
          id: :bonfire_cache,
          start:
            {Cachex, :start_link,
             [
               :bonfire_cache,
               [
                 expiration: Cachex.Spec.expiration(default: :timer.hours(default_cache_hours())),
                 # increase for instances with more users (at least num. of users*2+1)
                 hooks: [
                   # Cachex.Spec.hook(module: Cachex.Stats),
                   Cachex.Spec.hook(
                     module: Cachex.Limit.Scheduled,
                     args: {
                       # setting cache max size
                       2_500,
                       # options for `Cachex.prune/3`
                       [],
                       # options for `Cachex.Limit.Scheduled`
                       []
                     }
                   )
                 ]
                 # NOTE: limit is deprecated in 4.0, replaced by hooks ^
                 #  limit:
                 #    Cachex.Spec.limit(
                 #      # max number of entries
                 #      size: 2_500,
                 #      # the policy to use for eviction
                 #      policy: Cachex.Policy.LRW,
                 #      # what % to reclaim when limit is reached
                 #      reclaim: 0.1
                 #    )
               ]
             ]}
        }
      ] ++
        Bonfire.Common.Utils.maybe_apply(Bonfire.Social.Graph, :maybe_applications, [],
          fallback_return: []
        )

  # Stuff that depends on the Endpoint and/or the above
  def apps_after,
    do:
      maybe_oban() ++
        maybe_desktop_webapp()

  # ++ [
  #   {Tz.UpdatePeriodically, [interval_in_days: 10]}
  # ] 

  def maybe_oban do
    case Application.get_env(:bonfire, Oban, []) do
      [] ->
        []

      config ->
        [
          # Job Queue
          {Oban, config}
        ]
    end
  end

  @plug_protect {PlugAttack.Storage.Ets,
                 name: Bonfire.UI.Common.PlugProtect.Storage, clean_period: 60_000}

  def project, do: @project
  def config, do: @config
  def name, do: Application.get_env(:bonfire, :app_name) || config()[:name] || "Bonfire"
  def version, do: config()[:version]
  def named_version, do: "#{name()} #{version()}"
  def repository, do: project()[:sources_url] || project()[:source_url]
  def required_deps, do: project()[:required_deps]

  # NOTE: bellow was moved to `Bonfire`

  def start(_type, _args) do
    Bonfire.Common.Telemetry.setup(@env, @repo_module)
    IO.puts("Logging and telemetry are set up...")

    # FIXME
    # :gen_event.swap_handler(
    #   :alarm_handler,
    #   {:alarm_handler, :swap},
    #   {Bonfire.Common.Telemetry.SystemMonitor, :ok}
    # )
    # |> IO.inspect(label: "SystemMonitor is set up")

    # Application.get_env(:bonfire, Bonfire.Web.Endpoint, [])
    # |> IO.inspect()

    applications(
      @env,
      System.get_env("TEST_INSTANCE") == "yes",
      Bonfire.Common.Extend.module_enabled?(Bonfire.API.GraphQL) and
        Bonfire.Common.Extend.module_enabled?(Bonfire.API.GraphQL.Schema),
      System.get_env("AS_DESKTOP_APP") in ["1", "true"]
    )
    |> Enum.reject(&is_nil/1)
    |> IO.inspect(label: "apps tree")
    |> Supervisor.start_link(strategy: :one_for_one, name: @sup_name)
  end

  # include GraphQL API
  def applications(env, test_instance?, true = _with_graphql?, as_desktop) do
    IO.puts("Enabling the GraphQL API...")

    [
      # use persistent_term backend for Absinthe
      {Absinthe.Schema, Bonfire.API.GraphQL.Schema}
    ] ++
      applications(env, test_instance?, nil, as_desktop) ++
      [
        {Absinthe.Subscription, endpoint_module(as_desktop)}
      ]
  end

  def applications(_, true = _test_instance?, _any, as_desktop) do
    apps_before() ++
      [Bonfire.Common.TestInstanceRepo] ++
      [@plug_protect, endpoint_module(as_desktop), Bonfire.Web.FakeRemoteEndpoint] ++
      maybe_pages_beacon() ++
      apps_after()
  end

  # def applications(:test, _, _any, _as_desktop) do
  #   applications(nil, nil, nil)
  # end

  def applications(:dev, _, _any, as_desktop) do
    if Code.ensure_loaded?(CircularBuffer) do
      [
        # simple ETS based storage for non-prod
        {Bonfire.Common.Telemetry.Storage, Bonfire.Common.Telemetry.Metrics.metrics()}
      ]
    else
      []
    end ++ applications(nil, nil, nil, as_desktop)
  end

  # running as desktop app
  def applications(_env, _, _any, true) do
    endpoint_module = endpoint_module(true)

    apps_before() ++
      [@plug_protect, endpoint_module] ++
      maybe_pages_beacon() ++
      apps_after() ++
      [
        {Desktop.Window,
         [
           app: :bonfire,
           id: Bonfire,
           menubar: Bonfire.Desktop.MenuBar,
           icon_menu: Bonfire.Desktop.TaskMenu,
           title: "Bonfire",
           size: {900, 800},
           icon: "static/images/bonfire-icon.png",
           url: &endpoint_module.url/0
         ]}
      ]
  end

  # default apps
  def applications(_env, _, _any, _false) do
    apps_before() ++
      [@plug_protect, endpoint_module(false)] ++
      maybe_pages_beacon() ++
      apps_after()
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    endpoint_module().config_change(changed, removed)
    :ok
  end

  def endpoint_module(as_desktop \\ System.get_env("AS_DESKTOP_APP") in ["1", "true"])
  def endpoint_module(true), do: Bonfire.Desktop.Endpoint
  def endpoint_module(_false), do: @endpoint_module

  if Mix.target() == :app do
    defp maybe_desktop_webapp, do: [Bonfire.Desktop.WebApp]
  else
    defp maybe_desktop_webapp, do: []
  end

  def recompile do
    Phoenix.CodeReloader.reload(endpoint_module())
  end

  def recompile! do
    Application.stop(:bonfire)
    IEx.Helpers.recompile()
    Application.ensure_all_started(:bonfire)
  end

  def observer do
    Mix.ensure_application!(:wx)
    Mix.ensure_application!(:runtime_tools)
    Mix.ensure_application!(:observer)
    :observer.start()
  end

  # @doc "The system is restarted inside the running Erlang node, which means that the emulator is not restarted. All applications are taken down smoothly, all code is unloaded, and all ports are closed before the system is booted again in the same way as initially started."
  # def restart() do
  #   :init.restart()
  # end

  defp maybe_pages_beacon do
    if Bonfire.Common.Extend.module_enabled?(Beacon),
      do: [
        {Beacon,
         sites: [
           [
             site: :instance_site,
             endpoint: endpoint_module(),
             data_source: Bonfire.Pages.Beacon.DataSource
           ]
         ]}
      ],
      else: []
  end

  def finch_pool_config() do
    Config.get(:finch_pools, %{})
    |> maybe_add_sentry_pool()
  end

  def maybe_add_sentry_pool(pool_config) do
    case Bonfire.Common.Extend.extension_enabled?(:sentry) and Sentry.Config.dsn() do
      dsn when is_binary(dsn) ->
        Map.put(pool_config, dsn, size: 50)

      _ ->
        pool_config
    end
  end
end
