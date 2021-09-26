defmodule Bonfire.Repo.Migrations.TaxonomySeeder do
  use Ecto.Migration

  def up do
    Bonfire.TaxonomySeeder.Migrations.up()
    Bonfire.TaxonomySeeder.Migrations.add_category()
  end

  def down do
    Bonfire.TaxonomySeeder.Migrations.down()
  end

  # def change, do: nil

end
