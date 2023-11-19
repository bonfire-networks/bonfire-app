defmodule Bonfire.Boundaries.Repo.Migrations.BoundariesUsersFixturesUp do
  alias EctoSparkles.DataMigration
  use DataMigration

  @impl DataMigration
  def base_query do
    # NOTE: This works in cases where:
    # 1. The data can be queried with a condition that not longer applies after the migration ran, so you can repeatedly query the data and update the data until the query result is empty. For example, if a column is currently null and will be updated to not be null, then you can query for the null records and pick up where you left off.
    # 2. The migration is written in such a way that it can be ran several times on the same data without causing data loss or duplication (or crashing).

    # Notice how we do not use Ecto schemas here.
    from(u in Bonfire.Data.Identity.User,
      select: %{id: u.id}
    )
  end

  @impl DataMigration
  def config do
    %DataMigration.Config{
      # do not block app startup in auto-migrations
      async: true,
      # users at a time
      batch_size: 100,
      # wait a sec
      throttle_ms: 1_000,
      repo: Bonfire.Common.Repo,
      first_id: "00000000000000000000000000"
    }
  end

  @impl DataMigration
  def migrate(results) do
    Enum.each(results, fn user ->
      # hooks into a context module, which is more likely to be kept up to date as the app evolves, to avoid having to update old migrations

      Bonfire.Boundaries.Users.create_missing_boundaries(user)
    end)
  end
end
