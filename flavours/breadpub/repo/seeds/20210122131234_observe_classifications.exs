defmodule Bonfire.Repo.Seeds.ObserveClassifications do
  use Bonfire.Seeder

  envs [:dev, :prod, :test]

  def up(repo), do: ValueFlows.Observe.Seeds.up(repo)
end
