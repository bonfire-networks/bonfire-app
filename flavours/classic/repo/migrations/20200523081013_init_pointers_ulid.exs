defmodule Bonfire.Repo.Migrations.InitPointersULID do
  use Ecto.Migration
  # import Pointers.Migration
  import Pointers.ULID.Migration
  alias Bonfire.Data.Edges.Edge.Migration, as: Edge
  alias Bonfire.Data.Edges.EdgeTotal.Migration, as: EdgeTotal
  require Edge
  require EdgeTotal

  def change do
    init_pointers_ulid_extra()
  end

end
