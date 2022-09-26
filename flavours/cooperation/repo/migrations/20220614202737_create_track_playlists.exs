defmodule Rauversion.Repo.Migrations.CreateTrackPlaylists do
  use Ecto.Migration

  def change do
    create table(:track_playlists) do
      add(:track_id, references(:tracks, on_delete: :nothing))
      add(:playlist, references(:playlists, on_delete: :nothing))

      timestamps()
    end

    create(index(:track_playlists, [:track_id]))
    create(index(:track_playlists, [:playlist]))
  end
end
