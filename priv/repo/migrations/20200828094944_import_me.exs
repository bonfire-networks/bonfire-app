defmodule Bonfire.Repo.Migrations.ImportMe do
  use Ecto.Migration

  import Bonfire.Me.Migration
  # accounts & users

  def change, do: migrate_me()

end
