defmodule Bonfire.Repo.Migrations.InitPointers do
  use Ecto.Migration
  import Pointers.Migration

  def up do
    init_pointers_ulid_extra()
    init_pointers()
  end
  def down do
    init_pointers_ulid_extra()
    init_pointers()
  end

end
