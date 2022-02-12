defmodule Bonfire.Repo.Migrations.ImportValueFlows do
  use Ecto.Migration

  def up do
    if Code.ensure_loaded?(ValueFlows.AllMigrations), do: ValueFlows.AllMigrations.up
  end

  def down do
    if Code.ensure_loaded?(ValueFlows.AllMigrations), do: ValueFlows.AllMigrations.down
  end
end
