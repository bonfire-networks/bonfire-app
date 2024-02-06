defmodule Bonfire.Social.Repo.Migrations.RepliedTotal do
  @moduledoc false
  use Ecto.Migration

  def up, do: Bonfire.Data.Social.Replied.Migration.add_generated_total_column()
  def down, do: nil
end
