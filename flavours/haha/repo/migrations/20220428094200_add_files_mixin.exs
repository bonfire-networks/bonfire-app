defmodule Bonfire.Repo.Migrations.AddFilesMixin do
  use Ecto.Migration

  import Bonfire.Files.Migrations
  import Pointers.Migration

  def up do
    alter table("bonfire_files_media") do # cleanup old stuff
      remove_if_exists :created_at, :utc_datetime_usec
      remove_if_exists :updated_at, :utc_datetime_usec
    end

    Bonfire.Files.Migrations.migrate_files()
  end

  def down do
    Bonfire.Files.Migrations.migrate_files()
  end
end
