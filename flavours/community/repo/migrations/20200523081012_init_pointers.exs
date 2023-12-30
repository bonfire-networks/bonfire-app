defmodule Bonfire.Repo.Migrations.InitPointers do
  @moduledoc false
  use Ecto.Migration
  import Needle.Migration

  def up do
    init_pointers_ulid_extra()
    init_pointers()
  end

  def down do
    init_pointers_ulid_extra()
    init_pointers()
  end
end
