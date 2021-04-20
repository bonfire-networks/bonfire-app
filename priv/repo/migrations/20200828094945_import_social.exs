defmodule Bonfire.Social.Repo.Migrations.ImportSocial do
  use Ecto.Migration

  import Bonfire.Social.Migrations

  def up do 
  
    migrate_social()
  
    flush()

    alter table("bonfire_data_social_profile") do
      Ecto.Migration.add_if_not_exists :icon_id, strong_pointer(Bonfire.Files.Media)
      Ecto.Migration.add_if_not_exists :image_id, strong_pointer(Bonfire.Files.Media)
    end
  end
  
  def down, do: migrate_social()

end
