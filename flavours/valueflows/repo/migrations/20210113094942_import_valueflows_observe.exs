defmodule Bonfire.Repo.Migrations.ImportValueFlowsObserve do
  use Ecto.Migration

  alias ValueFlows.Observe.Migrations

  def up do
    if Code.ensure_loaded?(Migrations), do: Migrations.up
  end

  def down do
    if Code.ensure_loaded?(Migrations), do: Migrations.down
  end
end
