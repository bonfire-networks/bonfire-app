defmodule Bonfire.Repo.Migrations.ImportQuantify do
  use Ecto.Migration

  def up do
    if Code.ensure_loaded?(Bonfire.Quantify.Migrations) do
       Bonfire.Quantify.Migrations.change
       Bonfire.Quantify.Migrations.change_measure
    end
  end

  def down do
    if Code.ensure_loaded?(Bonfire.Quantify.Migrations) do
       Bonfire.Quantify.Migrations.change
       Bonfire.Quantify.Migrations.change_measure
    end
  end
end
