defmodule Rauversion.Repo.Migrations.CreatePurchaseOrders do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:purchase_orders) do
      add(:total, :decimal)
      add(:promo_code, :string)
      add(:data, :map)
      add(:state, :string)
      add(:user_id, RauversionExtension.user_table_reference())

      timestamps()
    end

    create(index(:purchase_orders, [:user_id]))
  end
end
