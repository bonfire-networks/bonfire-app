defmodule Bonfire.Repo.Migrations.Message do
  use Ecto.Migration

  import Bonfire.Data.Social.Message.Migration

  def up, do: migrate_message()
  def down, do: migrate_message()

end
