defmodule Bonfire.Repo.Migrations.AddFiles do
  use Ecto.Migration

  import Bonfire.Files.Media.Migration
  import Pointers.Migration

  def up do
    Bonfire.Files.Media.Migration.migrate_media()
  end

  def down do
    Bonfire.Files.Media.Migration.migrate_media()
  end
end
