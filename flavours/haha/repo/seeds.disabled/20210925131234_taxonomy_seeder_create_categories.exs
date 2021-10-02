defmodule Bonfire.Repo.Seeds.TaxonomySeeds do
  use Bonfire.Seeder

  envs [:dev, :prod, :test]

  def up(repo), do: Bonfire.TaxonomySeeder.ImportBatch.batch(repo)
end
