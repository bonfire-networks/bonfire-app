defmodule Rauversion.Repo.Migrations.AlterPlaylistFielfToTrackPlaylists do
  use Ecto.Migration

  def change do
    rename(table("track_playlists"), :playlist, to: :playlist_id)
  end
end
