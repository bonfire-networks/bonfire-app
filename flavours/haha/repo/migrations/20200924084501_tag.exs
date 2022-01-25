defmodule Bonfire.Repo.Migrations.Tag do
  use Ecto.Migration

  def up do
    Bonfire.Tag.Migrations.up()
  end

  def down do
    Bonfire.Tag.Migrations.down()
  end
end
