defmodule Rauversion.Repo.Migrations.CreatePreviewCards do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:preview_cards) do
      add(:url, :string)
      add(:title, :string)
      add(:description, :text)
      add(:type, :string)
      add(:author_name, :string)
      add(:author_url, :string)
      add(:html, :text)
      add(:image, :string)

      timestamps()
    end
  end
end
