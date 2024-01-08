defmodule Bonfire.Encrypt.Repo.Migrations.InitSecret do
  @moduledoc false
  use Ecto.Migration

  if Code.ensure_loaded?(Bonfire.Encrypt.Migrations) do
    require Bonfire.Encrypt.Migrations

    def up do
      Bonfire.Encrypt.Migrations.migrate_secret()
    end

    def down do
      Bonfire.Encrypt.Migrations.migrate_secret()
    end
  else
    IO.puts("Skip Bonfire.Encrypt migrations because the extension is not available.")
  end
end
