defmodule Bonfire.Repo.Migrations.ImportInviteLink do
  use Ecto.Migration

  def up do
    Bonfire.Invites.Link.Migration.up
  end

  def down do
    Bonfire.Invites.Link.Migration.down
  end
end
