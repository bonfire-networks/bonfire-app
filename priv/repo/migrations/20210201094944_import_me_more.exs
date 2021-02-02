defmodule Bonfire.Repo.Migrations.ImportMeMore do
  use Ecto.Migration

  import Bonfire.Data.Social.Replied.Migration
  # accounts & users

  def up, do: migrate_replied(:up)
  def down, do: migrate_replied(:down)

end
