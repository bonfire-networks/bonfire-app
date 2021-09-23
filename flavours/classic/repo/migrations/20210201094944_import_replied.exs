defmodule Bonfire.Repo.Migrations.ImportReplied do
  use Ecto.Migration

  import Bonfire.Data.Social.Replied.Migration

  def up do
    migrate_replied(:up)
    migrate_functions()
  end

  def down, do: migrate_replied(:down)

end
