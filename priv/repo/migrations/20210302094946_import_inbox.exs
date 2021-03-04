defmodule Bonfire.Repo.Migrations.ImportInbox do
  use Ecto.Migration

  import Bonfire.Data.Social.Inbox.Migration

  def change do
    migrate_inbox()
  end

end
