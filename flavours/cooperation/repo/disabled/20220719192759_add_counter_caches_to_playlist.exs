defmodule Rauversion.Repo.Migrations.AddCounterCachesToPlaylist do
  use Ecto.Migration

  def change do
    alter table(:playlists) do
      add(:likes_count, :integer, default: 0)
    end
  end
end
