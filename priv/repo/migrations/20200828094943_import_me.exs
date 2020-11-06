defmodule VoxPublica.Repo.Migrations.ImportMe do
  use Ecto.Migration

  def change do
    # accounts & users
    CommonsPub.Me.Migrations.change()

    # migrate_circle()

  end

end
