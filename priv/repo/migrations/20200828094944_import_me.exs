defmodule Bonfire.Repo.Migrations.ImportMe do
  use Ecto.Migration

  import Bonfire.Me.Migrations
  import Pointers.Migration

  def up do
    # accounts & users
    migrate_me()

    flush()

    alter table("bonfire_data_social_profile") do
      Ecto.Migration.add_if_not_exists :icon_id, strong_pointer(Bonfire.Files.Media)
      Ecto.Migration.add_if_not_exists :image_id, strong_pointer(Bonfire.Files.Media)
    end
  end

  def down, do: migrate_me()

end
