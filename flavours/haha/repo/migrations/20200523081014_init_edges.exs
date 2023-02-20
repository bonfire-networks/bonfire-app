defmodule Bonfire.Repo.Migrations.InitEdges do
  @moduledoc false
  use Ecto.Migration
  alias Bonfire.Data.Edges.Migration

  def up do
    Migration.up()
  end

  def down do
    Migration.down()
  end
end
