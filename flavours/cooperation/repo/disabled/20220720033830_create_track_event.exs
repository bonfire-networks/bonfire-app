defmodule Rauversion.Repo.Migrations.CreateTrackEvent do
  use Ecto.Migration

  def change do
    create table(:listening_events) do
      add(:remote_ip, :string)
      add(:country, :string)
      add(:city, :string)
      add(:ua, :string)
      add(:lang, :string)
      add(:referer, :string)
      add(:utm_medium, :string)
      add(:utm_source, :string)
      add(:utm_campaign, :string)
      add(:utm_content, :string)
      add(:utm_term, :string)
      add(:browser_name, :string)
      add(:browser_version, :string)
      add(:modern, :boolean)
      add(:platform, :string)
      add(:device_type, :string)
      add(:bot, :boolean)
      add(:search_engine, :boolean)

      add(:resource_profile_id, RauversionExtension.user_table_reference())
      add(:user_id, RauversionExtension.user_table_reference())
      add(:track_id, references(:tracks, on_delete: :nothing))
      add(:playlist_id, references(:tracks, on_delete: :nothing))

      timestamps()
    end

    create(index(:listening_events, [:resource_profile_id]))
    create(index(:listening_events, [:user_id]))
    create(index(:listening_events, [:track_id]))
    create(index(:listening_events, [:playlist_id]))
  end
end
