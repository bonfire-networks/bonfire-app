defmodule Rauversion.Repo.Migrations.CreateTracks do
  use Ecto.Migration

  def change do
    create table(:tracks) do
      add(:title, :string)
      add(:description, :text)
      add(:private, :boolean, default: false, null: false)
      add(:slug, :string)
      add(:caption, :text)
      add(:notification_settings, :map)
      add(:metadata, :map)
      add(:user_id, RauversionExtension.user_table_reference())

      timestamps()
    end

    create(index(:tracks, [:user_id]))
  end
end
