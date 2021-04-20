defmodule Bonfire.Social.Repo.Migrations.ImportSocial do
  use Ecto.Migration

  import Bonfire.Social.Migrations
  import Pointers.Migration

  def up do

    migrate_social()

    flush()

    # temporary hacks:
    drop_if_exists constraint "bonfire_data_social_profile", "bonfire_data_social_profile_icon_id_fkey"
    drop_if_exists constraint "bonfire_data_social_profile", "bonfire_data_social_profile_image_id_fkey"

    alter table("bonfire_data_social_profile") do
      Ecto.Migration.add_if_not_exists :icon_id, strong_pointer(Bonfire.Files.Media)
      Ecto.Migration.add_if_not_exists :image_id, strong_pointer(Bonfire.Files.Media)
    end
  end

  def down, do: migrate_social()

end
