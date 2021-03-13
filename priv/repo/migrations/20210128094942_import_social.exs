defmodule Bonfire.Social.Repo.Migrations.ImportSocial do
  use Ecto.Migration

  import Bonfire.Social.Migrations
  # accounts & users

  def change, do: migrate_social()

end
