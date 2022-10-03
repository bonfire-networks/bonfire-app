defmodule Bonfire.Application do
  @sup_name Bonfire.Supervisor
  @name Mix.Project.config()[:name]
  @otp_app Bonfire.Common.Config.get!(:otp_app)
  @env Application.compile_env!(@otp_app, :env)
  @version Mix.Project.config()[:version]
  @repository Mix.Project.config()[:source_url]
  @deps Bonfire.Common.Extend.loaded_deps()
  @endpoint_module Application.compile_env!(@otp_app, :endpoint_module)
  @repo_module Application.compile_env!(@otp_app, :repo_module)
  @required_deps Mix.Project.config()[:required_deps]

  use Application
  require Cachex.Spec

  def start(_type, _args) do
    EctoSparkles.Log.setup(@repo_module)
    # Ecto.DevLogger.install(@repo_module)

    Bonfire.ObanLogger.setup()
    Oban.Telemetry.attach_default_logger()

    # |> IO.inspect
    applications(
      @env,
      Bonfire.Common.Extend.module_enabled?(Bonfire.API.GraphQL) and
        Bonfire.Common.Extend.module_enabled?(Bonfire.API.GraphQL.Schema)
    )
    |> Supervisor.start_link(strategy: :one_for_one, name: @sup_name)
  end

  # include GraphQL API
  def applications(env, true = _with_graphql?) do
    IO.puts("Enabling the GraphQL API...")

    [
      # use persistent_term backend for Absinthe
      {Absinthe.Schema, Bonfire.API.GraphQL.Schema}
    ] ++
      applications(env, :default) ++
      [
        {Absinthe.Subscription, @endpoint_module}
      ]
  end

  @apps_before [
    # Metrics
    Bonfire.Web.Telemetry,
    # Database
    @repo_module,
    EctoSparkles.AutoMigrator,
    # Bonfire.Common.ConfigModules,
    # Bonfire.Common.Config.LoadExtensionsConfig,
    # load instance Settings from DB into Config
    Bonfire.Me.Settings.LoadInstanceConfig,
    # PubSub
    {Phoenix.PubSub, [name: Bonfire.PubSub, adapter: Phoenix.PubSub.PG2]},
    # Persistent Data Services
    Pointers.Tables,
    # Bonfire.Data.AccessControl.Accesses,
    ## these populate on first call, so no need to run on startup:
    # Bonfire.Common.ContextModules,
    # Bonfire.Common.QueryModules,
    # Bonfire.Federate.ActivityPub.FederationModules
    {PhoenixProfiler, name: Bonfire.Web.Profiler}
  ]

  # 6 hours
  @default_cache_ttl 1_000 * 60 * 60 * 6

  # Stuff that depends on the Endpoint and/or the above
  @apps_after [
    # Job Queue
    {Oban, Application.fetch_env!(:bonfire, Oban)},
    %{
      id: :bonfire_cache,
      start:
        {Cachex, :start_link,
         [
           :bonfire_cache,
           [
             expiration:
               Cachex.Spec.expiration(
                 default: @default_cache_ttl,
                 interval: 1000
               ),
             # increase for instances with more users (at least num. of users*2+1)
             limit: 5000
           ]
         ]}
    }
  ]

  def applications(:test, _any) do
    # ++ [Bonfire.Web.FakeRemoteEndpoint] # NOTE: enable for tests that require two running instances
    @apps_before ++
      [@endpoint_module] ++
      @apps_after
  end

  # default apps
  def applications(_env, _any) do
    @apps_before ++
      [@endpoint_module] ++
      @apps_after
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    @endpoint_module.config_change(changed, removed)
    :ok
  end

  def name(), do: Application.get_env(:bonfire, :app_name, @name)
  def version, do: @version
  def named_version, do: name() <> " " <> @version
  def repository, do: @repository
  def deps, do: @deps
  def required_deps, do: @required_deps
end
