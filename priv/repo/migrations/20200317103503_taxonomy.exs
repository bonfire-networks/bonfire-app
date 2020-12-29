defmodule CommonsPub.Repo.Migrations.Taxonomy do
  use Ecto.Migration

  def up do
    Bonfire.TaxonomySeeder.Migrations.up()
  end

  def down do
    Bonfire.TaxonomySeeder.Migrations.down()
  end
end
