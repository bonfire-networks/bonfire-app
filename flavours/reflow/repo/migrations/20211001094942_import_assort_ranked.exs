defmodule Bonfire.Repo.Migrations.ImportRanked do
  use Ecto.Migration
  require Bonfire.Data.Assort.Ranked.Migration

  def up, do: Bonfire.Data.Assort.Ranked.Migration.migrate_ranked
  def down, do: Bonfire.Data.Assort.Ranked.Migration.migrate_ranked

end
