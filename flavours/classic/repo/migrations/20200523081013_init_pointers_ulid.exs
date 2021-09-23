defmodule Bonfire.Repo.Migrations.InitPointersULID do
  use Ecto.Migration
  # import Pointers.Migration
  import Pointers.ULID.Migration

  def change do
    init_pointers_ulid_extra()
    # init_pointers()
  end

end
