defmodule Bonfire.Application do
  @moduledoc false

  @sup_name Bonfire.Supervisor
  @name Mix.Project.config()[:name]
  @version Mix.Project.config()[:version]
  @repository Mix.Project.config()[:source_url]

  use Application

  def start(_type, _args) do
    applications(Application.fetch_env!(:bonfire, :flavour)) #|> IO.inspect
    |> Supervisor.start_link(strategy: :one_for_one, name: @sup_name)
  end

  def applications(flavour) when flavour in ["coordination", "reflow"] do
    [
      {Absinthe.Schema, Bonfire.GraphQL.Schema} # use persistent_term backend for Absinthe
    ] ++ applications(nil)
  end

  def applications(_) do
    [ Bonfire.Web.Telemetry,                  # Metrics
      Bonfire.Repo,                           # Database
      {Phoenix.PubSub, name: Bonfire.PubSub}, # PubSub
      # Persistent Data Services
      Pointers.Tables,
      Bonfire.Data.AccessControl.Accesses,
      Bonfire.Data.AccessControl.Verbs,
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

end
