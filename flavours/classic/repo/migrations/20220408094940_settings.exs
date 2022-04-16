defmodule Bonfire.Repo.Migrations.ImportSettings do
  use Ecto.Migration
  require Bonfire.Data.Identity.Settings.Migration

  def up do
    Bonfire.Data.Identity.Settings.Migration.migrate_settings(:up)
  end

  def down do
    Bonfire.Data.Identity.Settings.Migration.migrate_settings(:up)
  end
end
