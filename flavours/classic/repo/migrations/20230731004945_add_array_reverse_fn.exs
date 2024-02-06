defmodule Bonfire.Social.Repo.Migrations.ArrayFn do
  @moduledoc false
  use Ecto.Migration

  def up, do: Bonfire.Social.Migrations.add_array_reverse_fn()
  def down, do: nil
end
