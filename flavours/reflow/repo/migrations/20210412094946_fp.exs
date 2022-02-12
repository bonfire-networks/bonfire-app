defmodule Bonfire.Repo.Migrations.FP do
  use Ecto.Migration


  def up do
    execute("create or replace function
    column_exists(ptable text, pcolumn text, pschema text default 'public')
      returns boolean
      language sql stable strict
    as $body$
        -- does the requested table.column exist in schema?
        select exists
            ( select null
                from information_schema.columns
                where table_name=ptable
                  and column_name=pcolumn
                  and table_schema=pschema
            );
    $body$;")

    execute("CREATE OR REPLACE FUNCTION rename_column_if_exists(ptable TEXT, pcolumn TEXT, new_name TEXT)
      RETURNS VOID AS $BODY$
    BEGIN
        -- Rename the column if it exists.
        IF column_exists(ptable, pcolumn) THEN
            EXECUTE FORMAT('ALTER TABLE IF EXISTS %I RENAME COLUMN %I TO %I;',
                ptable, pcolumn, new_name);
        END IF;
    END$BODY$
      LANGUAGE plpgsql VOLATILE;")

    flush()

    execute("SELECT rename_column_if_exists('bonfire_data_social_feed_publish', 'object_id', 'activity_id') ")

  end

  def down, do: nil

end
