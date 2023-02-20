defmodule Bonfire.Data.Identity.Repo.Migrations.CareClosure do
  @moduledoc false
  use Ecto.Migration

  alias Bonfire.Data.Identity.CareClosure.Migration

  def change, do: Migration.migrate_care_closure_view()
end
