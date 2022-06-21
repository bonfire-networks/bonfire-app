defmodule Bonfire.Repo.Migrations.AuthSecondFactor do
  use Ecto.Migration
  require Bonfire.Data.Identity.AuthSecondFactor.Migration

  def up do
    Bonfire.Data.Identity.AuthSecondFactor.Migration.migrate_auth_second_factor()
  end

  def down do
    Bonfire.Data.Identity.AuthSecondFactor.Migration.migrate_auth_second_factor()
  end
end
