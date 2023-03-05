defmodule Bonfire.Boundaries.Repo.Migrations.BoundariesFixtures do
  @moduledoc false
  use Ecto.Migration

  import Bonfire.Boundaries.Fixtures

  def up, do: Bonfire.Boundaries.Fixtures.insert()
end
