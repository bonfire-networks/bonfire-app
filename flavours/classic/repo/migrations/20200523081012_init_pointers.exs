defmodule Bonfire.Repo.Migrations.InitPointers do
  use Ecto.Migration
  import Pointers.Migration

  def change do
    init_pointers_ulid_extra()
    init_pointers()
  end

end
