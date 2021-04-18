defmodule Bonfire.Repo.Migrations.AddFiles do
  use Ecto.Migration

  import Bonfire.Files.Media.Migration
  import Pointers.Migration

  def up do
    Bonfire.Files.Media.Migration.migrate_media()

    alter table("bonfire_data_social_profile") do
      Ecto.Migration.add_if_not_exists :icon_id, strong_pointer(Bonfire.Files.Media)
      Ecto.Migration.add_if_not_exists :image_id, strong_pointer(Bonfire.Files.Media)
    end
  end

  def down do
    Bonfire.Files.Media.Migration.migrate_media()
  end
end
