defmodule Bonfire.Posts.Repo.Migrations.Import do
  @moduledoc false
  use Ecto.Migration

  import Bonfire.Posts.Migrations

  def change, do: migrate_posts()
end
