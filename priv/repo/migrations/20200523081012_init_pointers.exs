defmodule Bonfire.Repo.Migrations.InitPointers do
  use Ecto.Migration
  import Pointers.Migration
  import Pointers.ULID.Migration

  def up do
    execute "CREATE EXTENSION IF NOT EXISTS \"citext\""
    init_pointers_ulid_extra(:up)
    init_pointers(:up)
  end

  def down do
    init_pointers_ulid_extra(:down)
    init_pointers(:down)
    execute "DROP EXTENSION IF EXISTS \"citext\""
  end

end
