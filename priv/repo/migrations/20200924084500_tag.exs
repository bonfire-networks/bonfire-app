defmodule Bonfire.Repo.Migrations.AddTag do
  use Ecto.Migration

  def up do
    Bonfire.Tag.Migrations.up()
    Bonfire.Classify.Migrations.up()
  end

  def down do
    Bonfire.Tag.Migrations.down()
    Bonfire.Classify.Migrations.down()
  end
end
