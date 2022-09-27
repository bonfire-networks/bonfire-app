defmodule Bonfire.Pages.Repo.Migrations.ImportPages do
  use Ecto.Migration

  import Bonfire.Pages.Migrations
  import Pointers.Migration

  def up do
    migrate_pages()
  end

  def down, do: migrate_pages()
end
