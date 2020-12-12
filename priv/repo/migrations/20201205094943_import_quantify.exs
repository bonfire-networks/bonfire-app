defmodule Bonfire.Repo.Migrations.ImportQuantify do
  use Ecto.Migration

  def change do
    if Code.ensure_loaded?(Bonfire.Quantify.Migrations) do
       Bonfire.Quantify.Migrations.change
       Bonfire.Quantify.Migrations.change_measure
    end
  end
end
