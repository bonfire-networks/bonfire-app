defmodule Bonfire.Repo.Migrations.ImportMe do
  use Ecto.Migration

  # accounts & users

  def up do
    Bonfire.Me.Migrations.up()
  end

  def down do
    Bonfire.Me.Migrations.down()
  end

end
