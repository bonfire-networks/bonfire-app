defmodule Bonfire.Repo.Migrations.ImportMe do
  use Ecto.Migration

  import Bonfire.Me.Migrations

  def up do
    # accounts & users
    migrate_me()
  end

  def down, do: migrate_me()

end
