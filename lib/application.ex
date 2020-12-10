defmodule Bonfire.Application do
  @moduledoc false

  @sup_name Bonfire.Supervisor

  use Application

  def start(_type, _args) do
    [ Bonfire.Web.Telemetry,                  # Metrics
      Bonfire.Repo,                           # Database
      {Phoenix.PubSub, name: Bonfire.PubSub}, # PubSub
      # Persistent Data Services
      Pointers.Tables,
      Bonfire.Data.AccessControl.Accesses,
      Bonfire.Data.AccessControl.Verbs,
      # Stuff that uses all the above
      Bonfire.Web.Endpoint,                       # Webapp
      {Oban, Application.get_env(:bonfire, Oban)} # Job Queue
    ]
    |> Supervisor.start_link(strategy: :one_for_one, name: @sup_name)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Bonfire.Web.Endpoint.config_change(changed, removed)
    :ok
  end

end
