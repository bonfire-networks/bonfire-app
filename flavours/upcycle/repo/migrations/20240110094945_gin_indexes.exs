defmodule Bonfire.Search.Repo.Migrations.GinIndexes do
  use Ecto.Migration

  @disable_ddl_transaction true
  @disable_migration_lock true
  # ^ Needed to migrate indexes concurrently. 
  # Disabling DDL transactions removes the guarantee that all of the changes in the migration will happen at once. 
  # Disabling the migration lock removes the guarantee only a single node will run a given migration if multiple nodes are attempting to migrate at the same time.

  def up do
    execute "CREATE EXTENSION IF NOT EXISTS pg_trgm;"

    create_index("bonfire_data_social_named", "name")
    create_index("bonfire_data_identity_character", "username")

    # create_index("bonfire_data_social_profile", "name")
    create_index_fields(
      "bonfire_data_social_profile",
      "name gin_trgm_ops, summary gin_trgm_ops"
    )

    create_index_fields(
      "bonfire_data_social_post_content",
      # "name gin_trgm_ops, summary gin_trgm_ops, html_body gin_trgm_ops"
      "name gin_trgm_ops, summary gin_trgm_ops"
    )
  end

  def down do
    # TODO
  end

  def create_index(table, field) do
    create_index_fields(table, "#{field} gin_trgm_ops")
  end

  def create_index_fields(table, fields) do
    execute """
      DROP INDEX IF EXISTS #{table}_gin_index;
    """

    execute """
      CREATE INDEX CONCURRENTLY #{table}_gin_index 
        ON #{table} 
        USING gin (#{fields});
    """
  end
end
