defmodule Bonfire.Federate.ActivityPub.Repo.Migrations.ImportMe do
  use Ecto.Migration

  import Bonfire.Federate.ActivityPub.Migrations
  # accounts & users

  def change, do: migrate_activity_pub

end
