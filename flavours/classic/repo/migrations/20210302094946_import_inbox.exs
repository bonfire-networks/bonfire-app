defmodule Bonfire.Repo.Migrations.ImportInbox do
  use Ecto.Migration

  import Bonfire.Data.Social.Inbox.Migration

  def up, do: migrate_inbox()
  def down, do: migrate_inbox()

end
