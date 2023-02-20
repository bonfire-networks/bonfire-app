defmodule Bonfire.Repo.Migrations.UpdateObanJobsTable do
  @moduledoc false
  use Ecto.Migration

  def up, do: Oban.Migrations.up()

  def down, do: nil
end
