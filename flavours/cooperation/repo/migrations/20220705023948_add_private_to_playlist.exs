defmodule Rauversion.Repo.Migrations.AddPrivateToPlaylist do
  use Ecto.Migration

  def change do
    alter table(:playlists) do
      add(:private, :boolean)
    end
  end
end
