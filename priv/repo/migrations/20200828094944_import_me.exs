defmodule Bonfire.Repo.Migrations.ImportMe do
  use Ecto.Migration

  import Bonfire.Me.Migrations
  import Pointers.Migration

  def up do
    # accounts & users
    migrate_me()
  end

  def down, do: migrate_me()

end
