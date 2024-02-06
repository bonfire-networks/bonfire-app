defmodule Bonfire.Repo.Migrations.AddFilesMixin do
  @moduledoc false
  use Ecto.Migration

  import Bonfire.Files.Migrations
  import Needle.Migration

  def up do
    # cleanup old stuff
    alter table("bonfire_files_media") do
      remove_if_exists(:created_at, :utc_datetime_usec)
      remove_if_exists(:updated_at, :utc_datetime_usec)
    end

    Bonfire.Files.Migrations.migrate_files()
  end

  def down do
    Bonfire.Files.Migrations.migrate_files()
  end
end
