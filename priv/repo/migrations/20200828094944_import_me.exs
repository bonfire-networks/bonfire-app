defmodule Bonfire.Repo.Migrations.ImportMe do
  use Ecto.Migration

  import Bonfire.Me.Migrations
  # accounts & users

  def up, do: migrate_me()
  def down, do: migrate_me()

end
