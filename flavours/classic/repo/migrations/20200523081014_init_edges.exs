defmodule Bonfire.Repo.Migrations.InitEdges do
  use Ecto.Migration
  alias Bonfire.Data.Edges.Edge.Migration, as: Edge
  alias Bonfire.Data.Edges.EdgeTotal.Migration, as: EdgeTotal
  require Edge
  require EdgeTotal

  def up do
    Edge.migrate_edge()
    EdgeTotal.migrate_edge_total()
  end

  def down do
    EdgeTotal.migrate_edge_total()
    Edge.migrate_edge()
  end

end
