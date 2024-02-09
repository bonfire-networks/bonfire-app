defmodule Bonfire.Pages.Repo.Migrations.ImportPages do
  @moduledoc false
  use Ecto.Migration

  import Bonfire.Pages.Migrations
  import Needle.Migration

  def up do
    migrate_pages()
  end

  def down, do: migrate_pages()
end
