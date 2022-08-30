defmodule Bonfire.Repo.Migrations.ImportQuantify do
  use Ecto.Migration

  def up do
    Bonfire.Quantify.Migrations.change
       Bonfire.Quantify.Migrations.change_measure
  end

  def down do
    Bonfire.Quantify.Migrations.change
       Bonfire.Quantify.Migrations.change_measure
  end
end
