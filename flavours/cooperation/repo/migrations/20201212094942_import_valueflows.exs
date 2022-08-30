defmodule Bonfire.Repo.Migrations.ImportValueFlows do
  use Ecto.Migration

  def up do
    ValueFlows.AllMigrations.up
  end

  def down do
    ValueFlows.AllMigrations.down
  end
end
