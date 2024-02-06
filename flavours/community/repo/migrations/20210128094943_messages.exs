defmodule Bonfire.Messages.Repo.MessagesMigrations do
  @moduledoc false
  use Ecto.Migration

  import Bonfire.Messages.Migrations

  def change, do: migrate_messages()
end
