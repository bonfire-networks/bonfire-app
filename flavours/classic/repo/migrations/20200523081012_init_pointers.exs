defmodule Bonfire.Repo.Migrations.InitPointers do
  use Ecto.Migration
  import Pointers.Migration
  # import Pointers.ULID.Migration

  def up do
    init_pointers()
  end
  def down do
    init_pointers()
  end
end
