defmodule Bonfire.Repo.Migrations.Tagged do
  use Ecto.Migration

  def up do
    Bonfire.Tag.Migrations.up()
    flush()
    Bonfire.Tag.Migrations.tagged_up()
  end

  def down do
    Bonfire.Tag.Migrations.up()
    flush()
    Bonfire.Tag.Migrations.tagged_down()
  end
end
