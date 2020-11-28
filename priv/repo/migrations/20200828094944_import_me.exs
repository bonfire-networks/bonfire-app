defmodule Bonfire.Repo.Migrations.ImportMe do
  use Ecto.Migration

  # accounts & users

  def up do
    Bonfire.Me.Migration.up()
  end

  def down do
    Bonfire.Me.Migration.down()
  end

end
