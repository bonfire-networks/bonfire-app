defmodule Bonfire.Social.Repo.Migrations.AddVersions do
  use Ecto.Migration

  def change do
    Bonfire.Social.Migrations.add_paper_trail()
  end
end
