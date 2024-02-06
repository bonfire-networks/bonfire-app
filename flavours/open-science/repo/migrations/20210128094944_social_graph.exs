defmodule Bonfire.Social.Graph.Repo.Migrations.Import do
  @moduledoc false
  use Ecto.Migration

  import Bonfire.Social.Graph.Migrations

  def change, do: migrate_social_graph()
end
