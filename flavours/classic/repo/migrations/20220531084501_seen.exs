defmodule Bonfire.Repo.Migrations.Seen do
  use Ecto.Migration
  require Bonfire.Data.Social.Seen.Migration

  def up do
    Bonfire.Data.Social.Seen.Migration.migrate_seen()
  end

  def down do
    Bonfire.Data.Social.Seen.Migration.migrate_seen()
  end
end
