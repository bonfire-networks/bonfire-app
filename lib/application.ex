defmodule Bonfire.Application do
  @moduledoc false

  @sup_name Bonfire.Supervisor

  use Application

  def start(_type, _args) do
    [
      Pointers.Tables,
      Bonfire.Web.Telemetry,
      Bonfire.Repo,
      {Phoenix.PubSub, name: Bonfire.PubSub},
      Bonfire.Web.Endpoint,
      {Oban, Application.get_env(:bonfire, Oban)}
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
