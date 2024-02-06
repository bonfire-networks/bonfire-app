defmodule Bonfire.Federate.ActivityPub.Repo.Migrations.PeeredURI do
  @moduledoc false
  use Ecto.Migration

  import Needle.Migration

  def up do
    alter table("bonfire_data_activity_pub_peered") do
      Ecto.Migration.add_if_not_exists(:canonical_uri, :text, null: true)
    end
  end

  def down, do: nil
end
