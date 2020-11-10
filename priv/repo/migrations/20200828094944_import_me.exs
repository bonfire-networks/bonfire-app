defmodule Bonfire.Repo.Migrations.ImportMe do
  use Ecto.Migration

  def change do
    # accounts & users
    Bonfire.Me.Migrations.change()

    # migrate_circle()

  end

end
