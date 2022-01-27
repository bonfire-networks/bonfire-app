defmodule Bonfire.Social.Repo.Migrations.CharNotif do
  use Ecto.Migration

  import Pointers.Migration

  def up do
    alter table("bonfire_data_identity_character") do
      Ecto.Migration.add_if_not_exists :notifications_id, Pointers.Migration.weak_pointer()
    end
  end
  def down, do: nil

end
