defmodule Bonfire.Social.Repo.Migrations.PeeredURI do
  use Ecto.Migration

  import Pointers.Migration

  def up do
    alter table("bonfire_data_activity_pub_peered") do
      Ecto.Migration.add_if_not_exists :canonical_uri, :text, null: true
    end
  end
  def down, do: nil

end
