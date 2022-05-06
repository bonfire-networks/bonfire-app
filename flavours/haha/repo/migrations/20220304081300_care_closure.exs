defmodule Bonfire.Data.Identity.Repo.Migrations.CareClosure do
  use Ecto.Migration

  alias Bonfire.Data.Identity.CareClosure.Migration

  def change, do: Migration.migrate_care_closure_view()

end
