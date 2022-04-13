defmodule Bonfire.Repo.Migrations.ImportSettings do
  use Ecto.Migration
  require Bonfire.Data.Identity.Settings.Migration

  def change do
    Bonfire.Data.Identity.Settings.Migration.migrate_settings()
  end
end
