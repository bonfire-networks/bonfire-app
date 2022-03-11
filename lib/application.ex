defmodule Bonfire.Application do

  @sup_name Bonfire.Supervisor
  @name Mix.Project.config()[:name]
  @otp_app Bonfire.Common.Config.get!(:otp_app)
  @version Mix.Project.config()[:version]
  @repository Mix.Project.config()[:source_url]
  @deps Bonfire.Common.Extend.loaded_deps()

  use Application

  def start(_type, _args) do

    EctoSparkles.LogSlow.setup(@otp_app)

    :telemetry.attach("oban-errors", [:oban, :job, :exception], &Bonfire.ObanLogger.handle_event/4, [])
    Oban.Telemetry.attach_default_logger()

    applications() #|> IO.inspect
    |> Supervisor.start_link(strategy: :one_for_one, name: @sup_name)
  end

  def applications(with_graphql \\ Code.ensure_loaded?(Bonfire.GraphQL.Schema)) # TODO better

  def applications(true) do
    [
      {Absinthe.Schema, Bonfire.GraphQL.Schema} # use persistent_term backend for Absinthe
    ]
    ++ applications(false)
    ++
    [
      {Absinthe.Subscription, Bonfire.Web.Endpoint}
    ]
  end

  def applications(_) do
    [ Bonfire.Web.Telemetry,                  # Metrics
      Bonfire.Repo,                           # Database
      EctoSparkles.AutoMigrator,
      {Phoenix.PubSub, [name: Bonfire.PubSub, adapter: Phoenix.PubSub.PG2]}, # PubSub
      # Persistent Data Services
      Pointers.Tables,
      # Bonfire.Data.AccessControl.Accesses,
      Bonfire.Common.ContextModules,
      Bonfire.Common.QueryModules,
      Bonfire.Federate.ActivityPub.FederationModules,
      # Stuff that uses all the above
      Bonfire.Web.Endpoint,                       # Web app
      {Oban, Application.fetch_env!(:bonfire, Oban)} # Job Queue
    ]
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Bonfire.Web.Endpoint.config_change(changed, removed)
    :ok
  end

  def name(), do: Application.get_env(:bonfire, :app_name, @name)
  def version, do: @version
  def named_version, do: name() <> " " <> @version
  def repository, do: @repository
  def deps, do: @deps

end
