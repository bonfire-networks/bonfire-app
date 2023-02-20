defmodule Chaskiq.Repo.Migrations.CreateActiveStorageTables do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:active_storage_blobs) do
      # add :id, :uuid, primary_key: true, null: false
      add(:key, :string, null: false)
      add(:filename, :string, null: false)
      add(:content_type, :string)
      add(:metadata, :string)
      add(:service_name, :string, null: false)
      add(:byte_size, :integer, null: false)
      add(:checksum, :string)

      timestamps(inserted_at: :created_at, updated_at: :updated_at)
    end

    create(unique_index(:active_storage_blobs, [:key]))

    create table(:active_storage_attachments) do
      add(:name, :string, null: false)
      add(:record_id, :integer)
      add(:record_type, :string)

      add(:blob_id, :integer)
      add(:blob_type, :string)

      timestamps(inserted_at: :created_at, updated_at: :updated_at)
    end

    create(
      index("active_storage_attachments", [:record_type, :record_id, :name, :blob_id],
        name: :index_active_storage_attachments_uniqueness,
        unique: true
      )
    )

    create(
      index("active_storage_attachments", [:blob_id],
        name: :index_active_storage_attachments_on_blob_id,
        unique: false
      )
    )

    create table(:active_storage_variant_records) do
      # for binary types use:
      # add :blob_id, references(:active_storage_blobs, on_delete: :nothing, type: :binary_id)
      add(:blob_id, references(:active_storage_blobs, on_delete: :nothing))
      add(:variation_digest, :string, null: false)
      timestamps(inserted_at: :created_at, updated_at: :updated_at)
    end

    create(index(:active_storage_variant_records, [:blob_id, :variation_digest]))
    # with: [group_id: :group_id])
    # add :blob_id, references("active_storage_blobs")
  end
end
