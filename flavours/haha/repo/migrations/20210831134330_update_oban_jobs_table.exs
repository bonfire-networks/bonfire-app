defmodule Bonfire.Repo.Migrations.UpdateObanJobsTable do
  use Ecto.Migration

  def up, do: Oban.Migrations.up()

  def down, do: nil
end
