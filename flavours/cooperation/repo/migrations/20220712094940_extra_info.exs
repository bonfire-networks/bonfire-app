defmodule Bonfire.Repo.Migrations.ExtraInfo do
  use Ecto.Migration
  require Bonfire.Data.Identity.ExtraInfo.Migration

  def up do
    Bonfire.Data.Identity.ExtraInfo.Migration.migrate_extra_info(:up)
  end

  def down do
    Bonfire.Data.Identity.ExtraInfo.Migration.migrate_extra_info(:down)
  end
end
