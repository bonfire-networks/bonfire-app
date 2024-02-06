defmodule Bonfire.Federate.ActivityPub.Repo.Migrations.ImportAP do
  @moduledoc false
  use Ecto.Migration

  import Bonfire.Federate.ActivityPub.Migrations
  # accounts & users

  def up, do: migrate_activity_pub()
  def down, do: migrate_activity_pub()
end
