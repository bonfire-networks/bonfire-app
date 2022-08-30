defmodule Bonfire.Repo.Migrations.ImportValueFlowsObserve do
  use Ecto.Migration

  alias ValueFlows.Observe.Migrations

  def up do
    Migrations.up
  end

  def down do
    Migrations.down
  end
end
