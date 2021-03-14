defmodule Bonfire.Social.Repo.Migrations.ImportSocial do
  use Ecto.Migration

  import Bonfire.Social.Migrations

  def up, do: migrate_social()
  def down, do: migrate_social()

end
