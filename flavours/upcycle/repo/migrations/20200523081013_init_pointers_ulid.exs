defmodule Bonfire.Repo.Migrations.InitPointersULID do
  @moduledoc false
  use Ecto.Migration
  # import Needle.Migration
  import Needle.ULID.Migration

  def change do
    init_pointers_ulid_extra()
    # init_pointers()
  end
end
