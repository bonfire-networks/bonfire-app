defmodule Rauversion.Repo.Migrations.AddPurchaseOrderToPurchasedTickets do
  @moduledoc false
  use Ecto.Migration

  def change do
    alter table(:purchased_tickets) do
      add(:purchase_order_id, references(:purchase_orders, on_delete: :nothing))
    end
  end
end
