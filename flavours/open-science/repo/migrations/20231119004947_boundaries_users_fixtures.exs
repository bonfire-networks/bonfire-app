defmodule Bonfire.Boundaries.Repo.Migrations.BoundariesUsersFixturesUp do
  use Ecto.Migration

  def up() do
    Bonfire.Boundaries.FixturesUsersMigrations.up()
  end

  def down, do: :ok
end
