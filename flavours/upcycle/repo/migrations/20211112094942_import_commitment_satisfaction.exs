defmodule Bonfire.Repo.Migrations.ImportCommitmentSatisfaction do
  use Ecto.Migration

  def up do
    if Code.ensure_loaded?(ValueFlows.Planning.Commitment.Migrations) do
      ValueFlows.Planning.Commitment.Migrations.up()
      ValueFlows.Planning.Satisfaction.Migrations.up()
    end
  end

  def down do
    if Code.ensure_loaded?(ValueFlows.Planning.Commitment.Migrations) do
      ValueFlows.Planning.Satisfaction.Migrations.down()
      ValueFlows.Planning.Commitment.Migrations.down()
    end
  end
end
