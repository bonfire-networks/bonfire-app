defmodule Rauversion.Repo.Migrations.CreatePlaylists do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:playlists) do
      add(:slug, :string)
      add(:description, :text)
      add(:title, :string)
      add(:metadata, :map)
      add(:user_id, RauversionExtension.user_table_reference())

      timestamps()
    end

    create(index(:playlists, [:user_id]))
  end
end
