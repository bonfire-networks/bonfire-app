defmodule Bonfire.Repo.Migrations.ImportMe do
  use Ecto.Migration

  import Bonfire.Me.Migrations
  # accounts & users

  def change, do: migrate_me()

end
