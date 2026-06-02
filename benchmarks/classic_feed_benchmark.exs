defmodule Bonfire.ClassicFeedBenchmark do
  @moduledoc false

  alias Bonfire.Boundaries.Acls
  alias Bonfire.Common.Config
  alias Bonfire.Common.Repo
  alias Bonfire.Social.FeedActivities
  alias Bonfire.Social.Feeds

  @remote_feed "00000000-0000-4000-8000-ffffffffffff"
  @fetcher_subject "1ACT1V1TYPVBREM0TESFETCHER"

  @synthetic_min "00000000-0000-4000-8000-000000000000"
  @synthetic_max "00000000-0000-4000-8000-ffffffffffff"
  @churn_min "00000000-0000-4000-9000-000000000000"
  @churn_max "00000000-0000-4000-9000-ffffffffffff"

  def run do
    ensure_test_database_target!()
    start_application!()

    rows = env_int("BONFIRE_CLASSIC_FEED_ROWS", 50_000)
    iterations = env_int("BONFIRE_CLASSIC_BENCH_ITERATIONS", 7)
    limit = env_int("BONFIRE_CLASSIC_BENCH_LIMIT", 20)
    remote_every = env_int("BONFIRE_CLASSIC_REMOTE_EVERY", 10)
    fetcher_every = env_int("BONFIRE_CLASSIC_FETCHER_EVERY", 50)
    local_every = env_optional_int("BONFIRE_CLASSIC_LOCAL_EVERY")
    hidden_local_every = env_optional_int("BONFIRE_CLASSIC_HIDDEN_LOCAL_EVERY")
    hidden_local_burst_rows = env_int("BONFIRE_CLASSIC_HIDDEN_LOCAL_BURST_ROWS", 0)
    churn_rows = env_int("BONFIRE_CLASSIC_CHURN_ROWS", 0)
    keep_rows? = System.get_env("BONFIRE_CLASSIC_KEEP_ROWS") == "1"
    vacuum_after_churn? = System.get_env("BONFIRE_CLASSIC_VACUUM_AFTER_CHURN") == "1"
    vacuum_after_seed? = System.get_env("BONFIRE_CLASSIC_VACUUM_AFTER_SEED") == "1"
    warmup_runs = env_int("BONFIRE_CLASSIC_BENCH_WARMUP_RUNS", 0)

    ensure_test_database!()
    pagination_hard_max_limit = configure_feed_target(limit)
    configure_session()

    ids = static_ids()
    table_id = table_id!("bonfire_data_social_post")
    verb_id = verb_id!("Create")

    try do
      cleanup_churn_rows()
      cleanup_synthetic_rows()
      cleanup_benchmark_static_rows(ids, table_id)
      ensure_static_pointers(ids, table_id)

      seed_and_delete_churn_rows(churn_rows, table_id, verb_id, ids)
      if vacuum_after_churn?, do: vacuum_feed_tables()

      seed_classic_like_rows(
        rows,
        remote_every,
        fetcher_every,
        local_every,
        hidden_local_every,
        hidden_local_burst_rows,
        table_id,
        verb_id,
        ids
      )

      if vacuum_after_seed?, do: vacuum_feed_tables("after_seed")
      seed_integrity = validate_seed_integrity!(ids, rows)
      unless vacuum_after_seed?, do: analyze_feed_tables()

      index_info = index_info()
      counts = counts(ids)
      relation_sizes = relation_sizes()
      {cold_first_timing, warmup_timings, first_timing} = warmup_then_time(warmup_runs, limit)
      page_walk = page_walk(limit)
      explain = explain(limit, explain_after_cursor(page_walk))
      plan_flags = plan_flags(explain)
      explain_json = explain_json(limit, explain_after_cursor(page_walk))
      plan_metrics = plan_metrics(explain_json)
      timings = timings(iterations, limit)
      requirements = requirements(limit)

      report = %{
        counts: counts,
        churn_rows: churn_rows,
        explain: explain,
        fetcher_every: fetcher_every,
        cold_first_timing: cold_first_timing,
        first_timing: first_timing,
        fast_seed?: fast_seed?(),
        hidden_local_every: hidden_local_every,
        hidden_local_burst_rows: hidden_local_burst_rows,
        index_info: index_info,
        iterations: iterations,
        keep_rows?: keep_rows?,
        limit: limit,
        local_every: local_every,
        page_walk: page_walk,
        pagination_hard_max_limit: pagination_hard_max_limit,
        plan_flags: plan_flags,
        plan_metrics: plan_metrics,
        remote_every: remote_every,
        requirements: requirements,
        relation_sizes: relation_sizes,
        rows: rows,
        seed_integrity: seed_integrity,
        timings: timings,
        vacuum_after_churn?: vacuum_after_churn?,
        vacuum_after_seed?: vacuum_after_seed?,
        warmup_runs: warmup_runs,
        warmup_timings: warmup_timings
      }

      print_report(report)
      enforce_requirements!(report)
    after
      unless keep_rows? do
        cleanup_churn_rows()
        cleanup_synthetic_rows()
        cleanup_benchmark_static_rows(ids, table_id)
        IO.puts("cleanup=synthetic_rows_removed")
      end
    end
  end

  defp start_application! do
    Enum.each([:ecto, :db_connection, :postgrex, :ecto_sql, :phoenix_pubsub], &ensure_started!/1)
    ensure_pubsub_started()

    Mix.Task.run("ecto.create")
    start_repo!()

    if System.get_env("BONFIRE_LIGHTWEIGHT_TEST_MIGRATE") == "1" do
      Mix.Task.run("ecto.migrate")
      run_extension_migrations_strict!()
    end
  end

  defp run_extension_migrations_strict! do
    results = EctoSparkles.Migrator.migrate_repo(Repo, continue_on_error: true)
    failures = Enum.reject(results, &match?({:ok, _version, _desc}, &1))

    case failures do
      [] -> :ok
      failures -> raise "Extension migrations failed: #{inspect(failures)}"
    end
  end

  defp ensure_started!(app) do
    case Application.ensure_all_started(app) do
      {:ok, _apps} ->
        :ok

      {:error, reason} ->
        raise "Could not start #{inspect(app)} for benchmark: #{inspect(reason)}"
    end
  end

  defp ensure_pubsub_started do
    unless Process.whereis(Bonfire.Common.PubSub) do
      Supervisor.start_link(
        [{Phoenix.PubSub, name: Bonfire.Common.PubSub}],
        strategy: :one_for_one
      )
    end
  end

  defp start_repo! do
    case Repo.start_link() do
      {:ok, _pid} ->
        :ok

      {:error, {:already_started, _pid}} ->
        :ok

      {:error, reason} ->
        raise "Could not start #{inspect(Repo)} for benchmark: #{inspect(reason)}"
    end
  end

  defp configure_feed_target(limit) do
    Config.put([Bonfire.Social.Feeds, :query_with_deferred_join], true)
    Config.put([Bonfire.UI.Social.FeedLive, :time_limit], 0)

    hard_max =
      env_int("BONFIRE_CLASSIC_BENCH_HARD_MAX_LIMIT", max(limit * 32 + 1, 500))
      |> max(limit)

    Config.put(:pagination_hard_max_limit, hard_max)
    hard_max
  end

  defp configure_session do
    set_if_present("BONFIRE_CLASSIC_BENCH_WORK_MEM", "work_mem")
    set_if_present("BONFIRE_CLASSIC_BENCH_EFFECTIVE_CACHE_SIZE", "effective_cache_size")
    set_if_present("BONFIRE_CLASSIC_BENCH_RANDOM_PAGE_COST", "random_page_cost")
  end

  defp set_if_present(env, setting) do
    case System.get_env(env) do
      nil -> :ok
      "" -> :ok
      value -> Repo.query!("SET #{setting} = '#{String.replace(value, "'", "''")}'")
    end
  end

  defp ensure_test_database! do
    %{rows: [[database]]} = Repo.query!("select current_database()")

    unless test_database_name?(database) or
             System.get_env("BONFIRE_CLASSIC_BENCH_ALLOW_NON_TEST") == "1" do
      raise """
      Refusing to seed benchmark rows into #{database}.
      Use a test DATABASE_URL or set BONFIRE_CLASSIC_BENCH_ALLOW_NON_TEST=1 intentionally.
      """
    end
  end

  defp ensure_test_database_target! do
    database =
      database_from_url(System.get_env("DATABASE_URL")) ||
        System.get_env("POSTGRES_DB") ||
        database_from_loaded_config()

    if database &&
         not test_database_name?(database) &&
         System.get_env("BONFIRE_CLASSIC_BENCH_ALLOW_NON_TEST") != "1" do
      raise """
      Refusing to create, migrate, or seed benchmark rows into #{database}.
      Use a test DATABASE_URL or set BONFIRE_CLASSIC_BENCH_ALLOW_NON_TEST=1 intentionally.
      """
    end
  end

  defp database_from_url(nil), do: nil
  defp database_from_url(""), do: nil

  defp database_from_url(url) do
    case URI.parse(url).path do
      "/" <> database when database != "" -> URI.decode(database)
      _ -> nil
    end
  end

  defp database_from_loaded_config do
    Application.get_env(:bonfire, Repo, [])[:database] ||
      Application.get_env(:bonfire_common, Repo, [])[:database]
  end

  defp test_database_name?(database) when is_binary(database),
    do: String.contains?(database, "_test")

  defp test_database_name?(_), do: false

  defp static_ids do
    %{
      fetcher_subject: db_uid!(@fetcher_subject),
      hidden_acl: named_acl_uid!(:locals_may_see),
      local_feed: named_feed_uid!(:local),
      visible_acl:
        named_acl_uid!(env_existing_atom("BONFIRE_CLASSIC_VISIBLE_ACL", :everyone_may_see_read)),
      remote_feed: db_uid!(@remote_feed)
    }
  end

  defp named_feed_uid!(name) do
    case Feeds.named_feed_id(name) do
      id when is_binary(id) ->
        db_uid!(id)

      other ->
        raise "Expected #{inspect(name)} to have a persisted feed id, got #{inspect(other)}"
    end
  end

  defp named_acl_uid!(name) do
    case Acls.get_id(name) do
      id when is_binary(id) ->
        db_uid!(id)

      other ->
        raise "Expected #{inspect(name)} to have a persisted ACL id, got #{inspect(other)}"
    end
  end

  defp env_existing_atom(env, default) do
    case System.get_env(env) do
      nil ->
        default

      "" ->
        default

      value ->
        try do
          String.to_existing_atom(value)
        rescue
          ArgumentError -> raise "Unknown #{env}=#{inspect(value)}"
        end
    end
  end

  defp db_uid!(encoded) do
    case Ecto.UUID.dump(encoded) do
      {:ok, uid} ->
        uid

      :error ->
        case Needle.UID.dump(encoded) do
          {:ok, uid} -> uid
          _ -> encoded |> Needle.UID.synthesise!() |> Needle.UID.dump!()
        end
    end
  end

  defp table_id!(table) do
    %{rows: [[id]]} =
      Repo.query!("select id from pointers_table where \"table\" = $1", [table])

    id
  end

  defp verb_id!(verb) do
    %{rows: [[id]]} =
      Repo.query!("select id from bonfire_data_access_control_verb where verb = $1", [verb])

    id
  end

  defp cleanup_synthetic_rows do
    cleanup_rows_in_range(@synthetic_min, @synthetic_max)
  end

  defp cleanup_churn_rows do
    cleanup_rows_in_range(@churn_min, @churn_max)
  end

  defp cleanup_rows_in_range(min_id, max_id) do
    id_range = [Ecto.UUID.dump!(min_id), Ecto.UUID.dump!(max_id)]
    batch_size = env_int("BONFIRE_CLASSIC_CLEANUP_BATCH", 25_000)

    Enum.each(
      [
        "bonfire_data_social_feed_publish",
        "bonfire_data_access_control_controlled",
        "bonfire_data_social_activity",
        "pointers_pointer"
      ],
      &delete_rows_in_range(&1, id_range, batch_size)
    )
  end

  defp delete_rows_in_range(table, id_range, batch_size) do
    %{num_rows: rows} =
      Repo.query!(
        """
        with doomed as (
          select id
          from #{table}
          where id >= $1::uuid and id <= $2::uuid
          limit $3
        )
        delete from #{table} target
        using doomed
        where target.id = doomed.id
        """,
        id_range ++ [batch_size],
        timeout: :infinity
      )

    if rows == batch_size do
      delete_rows_in_range(table, id_range, batch_size)
    end
  end

  defp cleanup_benchmark_static_rows(ids, table_id) do
    Repo.query!(
      """
      delete from pointers_pointer pointer
      where pointer.id = $1::uuid
        and pointer.table_id = $2::uuid
        and not exists (
          select 1
          from bonfire_data_social_activity activity
          where activity.id = pointer.id
             or activity.subject_id = pointer.id
             or activity.object_id = pointer.id
        )
        and not exists (
          select 1
          from bonfire_data_social_feed_publish feed_publish
          where feed_publish.id = pointer.id
             or feed_publish.feed_id = pointer.id
        )
      """,
      [ids.fetcher_subject, table_id],
      timeout: :infinity
    )
  end

  defp ensure_static_pointers(ids, table_id) do
    ensure_pointer_exists!(ids.local_feed, "local feed")

    Repo.query!(
      """
      insert into pointers_pointer (id, table_id)
      values ($1, $3), ($2, $3)
      on conflict (id) do nothing
      """,
      [ids.remote_feed, ids.fetcher_subject, table_id]
    )
  end

  defp ensure_pointer_exists!(id, label) do
    %{num_rows: rows} =
      Repo.query!("select 1 from pointers_pointer where id = $1::uuid limit 1", [id])

    if rows != 1, do: raise("Expected #{label} pointer to exist before benchmark")
  end

  defp seed_classic_like_rows(
         rows,
         remote_every,
         fetcher_every,
         local_every,
         hidden_local_every,
         hidden_local_burst_rows,
         table_id,
         verb_id,
         ids
       ) do
    seed_batch_size = env_int("BONFIRE_CLASSIC_SEED_BATCH", 25_000)

    each_batch("main", rows, seed_batch_size, fn offset, batch_rows ->
      with_seed_acceleration(fn ->
        seed_classic_like_row_batch(
          offset,
          batch_rows,
          rows,
          remote_every,
          fetcher_every,
          local_every,
          hidden_local_every,
          hidden_local_burst_rows,
          table_id,
          verb_id,
          ids
        )
      end)
    end)
  end

  defp seed_classic_like_row_batch(
         offset,
         rows,
         total_rows,
         remote_every,
         fetcher_every,
         local_every,
         hidden_local_every,
         hidden_local_burst_rows,
         table_id,
         verb_id,
         ids
       ) do
    Repo.query!(
      """
      with generated as (
        select
          ('00000000-0000-4000-8000-' || lpad(to_hex(gs), 12, '0'))::uuid as id,
          case
            when $14 > 0 and gs > $15 - $14 then $5::uuid
            when $10 > 0 and gs % $10 = 0 then $5::uuid
            when $12 > 0 and gs % $12 = 0 then $5::uuid
            when $10 > 0 then $6::uuid
            when $3 > 0 and gs % $3 = 0 then $6::uuid
            else $5::uuid
          end as feed_id,
          case when $4 > 0 and gs % $4 = 0 then $7::uuid else $5::uuid end as subject_id,
          case
            when $14 > 0 and gs > $15 - $14 then $13::uuid
            when $10 > 0 and gs % $10 = 0 then $11::uuid
            when $12 > 0 and gs % $12 = 0 then $13::uuid
            else $11::uuid
          end as acl_id
        from generate_series($1 + 1, $1 + $2) as gs
      ),
      pointer_insert as (
        insert into pointers_pointer (id, table_id)
        select id, $8::uuid from generated
        on conflict (id) do nothing
      ),
      activity_insert as (
        insert into bonfire_data_social_activity (id, subject_id, object_id, verb_id)
        select id, subject_id, id, $9::uuid from generated
        on conflict (id) do nothing
      ),
      controlled_insert as (
        insert into bonfire_data_access_control_controlled (id, acl_id)
        select id, acl_id from generated
        on conflict (id, acl_id) do nothing
      )
      insert into bonfire_data_social_feed_publish (id, feed_id)
      select id, feed_id from generated
      on conflict (id, feed_id) do nothing
      """,
      [
        offset,
        rows,
        remote_every,
        fetcher_every,
        ids.local_feed,
        ids.remote_feed,
        ids.fetcher_subject,
        table_id,
        verb_id,
        local_every || 0,
        ids.visible_acl,
        hidden_local_every || 0,
        ids.hidden_acl,
        hidden_local_burst_rows,
        total_rows
      ],
      timeout: :infinity
    )
  end

  defp seed_and_delete_churn_rows(0, _table_id, _verb_id, _ids), do: :ok

  defp seed_and_delete_churn_rows(rows, table_id, verb_id, ids) do
    seed_batch_size = env_int("BONFIRE_CLASSIC_SEED_BATCH", 25_000)

    each_batch("churn", rows, seed_batch_size, fn offset, batch_rows ->
      with_seed_acceleration(fn ->
        Repo.query!(
          """
          with generated as (
            select
              ('00000000-0000-4000-9000-' || lpad(to_hex(gs), 12, '0'))::uuid as id
            from generate_series($1 + 1, $1 + $2) as gs
          ),
          pointer_insert as (
            insert into pointers_pointer (id, table_id)
            select id, $3::uuid from generated
            on conflict (id) do nothing
          ),
          activity_insert as (
            insert into bonfire_data_social_activity (id, subject_id, object_id, verb_id)
            select id, $4::uuid, id, $5::uuid from generated
            on conflict (id) do nothing
          ),
          controlled_insert as (
            insert into bonfire_data_access_control_controlled (id, acl_id)
            select id, $6::uuid from generated
            on conflict (id, acl_id) do nothing
          )
          insert into bonfire_data_social_feed_publish (id, feed_id)
          select id, $7::uuid from generated
          on conflict (id, feed_id) do nothing
          """,
          [
            offset,
            batch_rows,
            table_id,
            ids.local_feed,
            verb_id,
            ids.visible_acl,
            ids.local_feed
          ],
          timeout: :infinity
        )
      end)
    end)

    cleanup_churn_rows()
  end

  defp each_batch(label, rows, batch_size, fun) when rows > 0 do
    0
    |> Stream.iterate(&(&1 + batch_size))
    |> Enum.take_while(&(&1 < rows))
    |> Enum.each(fn offset ->
      batch_rows = min(batch_size, rows - offset)
      IO.puts("seed_batch=#{label}:#{offset + 1}-#{offset + batch_rows}/#{rows}")
      fun.(offset, batch_rows)
    end)
  end

  defp with_seed_acceleration(fun) do
    if fast_seed?() do
      case Repo.transaction(
             fn ->
               Repo.query!("SET LOCAL session_replication_role = replica")
               fun.()
             end,
             timeout: :infinity
           ) do
        {:ok, result} -> result
        {:error, reason} -> raise "Fast seed transaction failed: #{inspect(reason)}"
      end
    else
      fun.()
    end
  end

  defp fast_seed?, do: System.get_env("BONFIRE_CLASSIC_FAST_SEED") == "1"

  defp analyze_feed_tables do
    Repo.query!("analyze pointers_pointer")
    Repo.query!("analyze bonfire_data_access_control_controlled")
    Repo.query!("analyze bonfire_data_social_activity")
    Repo.query!("analyze bonfire_data_social_feed_publish")
  end

  defp vacuum_feed_tables(label \\ "after_churn") do
    IO.puts("vacuum_#{label}=begin")
    Repo.query!("vacuum (analyze) pointers_pointer", [], timeout: :infinity)
    Repo.query!("vacuum (analyze) bonfire_data_access_control_controlled", [], timeout: :infinity)
    Repo.query!("vacuum (analyze) bonfire_data_social_activity", [], timeout: :infinity)
    Repo.query!("vacuum (analyze) bonfire_data_social_feed_publish", [], timeout: :infinity)
    IO.puts("vacuum_#{label}=done")
  end

  defp index_info do
    Repo.query!("""
    select indexname, indexdef
    from pg_indexes
    where tablename = 'bonfire_data_social_feed_publish'
      and indexname like '%feed_id%'
    order by indexname
    """).rows
  end

  defp relation_sizes do
    Repo.query!("""
    select
      relname,
      pg_size_pretty(pg_relation_size(oid)) as table_size,
      pg_size_pretty(pg_indexes_size(oid)) as indexes_size,
      pg_size_pretty(pg_total_relation_size(oid)) as total_size
    from pg_class
    where relname in (
      'bonfire_data_social_feed_publish',
      'bonfire_data_social_activity',
      'bonfire_data_access_control_controlled',
      'pointers_pointer'
    )
    order by relname
    """).rows
  end

  defp validate_seed_integrity!(ids, expected_rows) do
    synthetic_range = [Ecto.UUID.dump!(@synthetic_min), Ecto.UUID.dump!(@synthetic_max)]

    IO.puts("seed_integrity_check=feed_publish")
    feed_publish_rows = count_range_rows("bonfire_data_social_feed_publish", synthetic_range)

    IO.puts("seed_integrity_check=pointers_pointer")

    pointer_rows =
      count_range_rows("pointers_pointer", synthetic_range, exclude_id: ids.remote_feed)

    IO.puts("seed_integrity_check=bonfire_data_social_activity")
    activity_rows = count_range_rows("bonfire_data_social_activity", synthetic_range)

    IO.puts("seed_integrity_check=bonfire_data_access_control_controlled")
    controlled_rows = count_range_rows("bonfire_data_access_control_controlled", synthetic_range)

    integrity = [
      feed_publish_rows - expected_rows,
      feed_publish_rows - pointer_rows,
      feed_publish_rows - activity_rows,
      feed_publish_rows - controlled_rows
    ]

    if Enum.any?(integrity, &(&1 != 0)) do
      raise "Synthetic seed integrity failed: #{inspect(integrity)}"
    end

    integrity
  end

  defp count_range_rows(table, id_range, opts \\ []) do
    exclude_id = Keyword.get(opts, :exclude_id)
    exclude_filter = if exclude_id, do: "and id <> $3::uuid", else: ""
    params = if exclude_id, do: id_range ++ [exclude_id], else: id_range

    %{rows: [[rows]]} =
      Repo.query!(
        """
        select count(*)
        from #{table}
        where id >= $1::uuid and id <= $2::uuid
          #{exclude_filter}
        """,
        params,
        timeout: :infinity
      )

    rows
  end

  defp counts(ids) do
    synthetic_range = [Ecto.UUID.dump!(@synthetic_min), Ecto.UUID.dump!(@synthetic_max)]

    %{rows: rows} =
      Repo.query!(
        """
        select
          count(*) filter (where fp.feed_id = $1::uuid) as local_rows,
          count(*) filter (where fp.feed_id = $2::uuid) as remote_rows,
          count(*) filter (
            where fp.feed_id = $1::uuid and controlled.acl_id <> $6::uuid
          ) as hidden_local_rows,
          count(*) filter (
            where fp.feed_id = $1::uuid
              and controlled.acl_id = $6::uuid
              and activity.subject_id = $5::uuid
          ) as local_fetcher_rows,
          count(*) filter (
            where fp.feed_id = $1::uuid
              and controlled.acl_id = $6::uuid
              and activity.subject_id <> $5::uuid
          ) as visible_local_rows,
          count(*) as feed_publish_rows
        from bonfire_data_social_feed_publish fp
        join bonfire_data_social_activity activity on activity.id = fp.id
        join bonfire_data_access_control_controlled controlled on controlled.id = fp.id
        where fp.id >= $3::uuid and fp.id <= $4::uuid
        """,
        [ids.local_feed, ids.remote_feed] ++
          synthetic_range ++ [ids.fetcher_subject, ids.visible_acl],
        timeout: :infinity
      )

    rows
  end

  defp explain(limit, after_cursor) do
    query =
      :local
      |> FeedActivities.feed(feed_opts(limit, after_cursor) ++ [return: :query])

    {sql, params} = Ecto.Adapters.SQL.to_sql(:all, Repo, query)

    Repo.query!(
      "EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT) " <> sql,
      params,
      timeout: :infinity
    ).rows
    |> Enum.map_join("\n", fn [line] -> line end)
  end

  defp explain_json(limit, after_cursor) do
    query =
      :local
      |> FeedActivities.feed(feed_opts(limit, after_cursor) ++ [return: :query])

    {sql, params} = Ecto.Adapters.SQL.to_sql(:all, Repo, query)

    Repo.query!(
      "EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON) " <> sql,
      params,
      timeout: :infinity
    ).rows
    |> decode_explain_json()
  end

  defp decode_explain_json([[[plan]]]), do: decode_explain_json_value(plan)
  defp decode_explain_json([[plan]]), do: decode_explain_json_value(plan)

  defp decode_explain_json_value([plan | _]) when is_map(plan), do: plan

  defp decode_explain_json_value(plan) when is_map(plan), do: plan

  defp decode_explain_json_value(json) when is_binary(json) do
    json
    |> Jason.decode!()
    |> List.first()
  end

  defp plan_flags(explain) do
    %{
      feed_publish_target_index_used:
        String.contains?(explain, "bonfire_data_social_feed_publish_feed_id_id_idx"),
      feed_publish_pkey_used: String.contains?(explain, "bonfire_data_social_feed_publish_pkey"),
      feed_publish_seq_scan_used:
        String.contains?(explain, "Seq Scan on bonfire_data_social_feed_publish")
    }
  end

  defp plan_metrics(explain_json) do
    nodes =
      explain_json
      |> Map.get("Plan")
      |> plan_nodes()

    feed_nodes =
      Enum.filter(nodes, &(Map.get(&1, "Relation Name") == "bonfire_data_social_feed_publish"))

    feed_publish_nodes =
      Enum.map(feed_nodes, fn node ->
        %{
          actual_loops: number_field(node, "Actual Loops"),
          actual_rows: number_field(node, "Actual Rows"),
          heap_fetches: integer_field(node, "Heap Fetches"),
          index_name: Map.get(node, "Index Name"),
          node_type: Map.get(node, "Node Type"),
          rows_removed_by_filter: integer_field(node, "Rows Removed by Filter"),
          shared_hit_blocks: integer_field(node, "Shared Hit Blocks"),
          shared_read_blocks: integer_field(node, "Shared Read Blocks"),
          temp_read_blocks: integer_field(node, "Temp Read Blocks"),
          temp_written_blocks: integer_field(node, "Temp Written Blocks")
        }
      end)

    %{
      feed_publish_actual_rows:
        Enum.reduce(feed_publish_nodes, 0.0, fn node, total ->
          total + node.actual_rows * max(node.actual_loops, 1.0)
        end),
      feed_publish_heap_fetches: sum_plan_metric(feed_publish_nodes, :heap_fetches),
      feed_publish_nodes: feed_publish_nodes,
      feed_publish_rows_removed_by_filter:
        sum_plan_metric(feed_publish_nodes, :rows_removed_by_filter),
      feed_publish_shared_read_blocks: sum_plan_metric(feed_publish_nodes, :shared_read_blocks),
      feed_publish_temp_blocks:
        sum_plan_metric(feed_publish_nodes, :temp_read_blocks) +
          sum_plan_metric(feed_publish_nodes, :temp_written_blocks),
      plan_seq_scan_nodes:
        nodes
        |> Enum.filter(&(Map.get(&1, "Node Type") == "Seq Scan"))
        |> Enum.map(&Map.get(&1, "Relation Name")),
      plan_temp_blocks:
        Enum.reduce(nodes, 0, fn node, total ->
          total + integer_field(node, "Temp Read Blocks") +
            integer_field(node, "Temp Written Blocks")
        end)
    }
  end

  defp plan_nodes(nil), do: []

  defp plan_nodes(node) when is_map(node) do
    [node | Enum.flat_map(Map.get(node, "Plans", []), &plan_nodes/1)]
  end

  defp sum_plan_metric(nodes, key), do: Enum.reduce(nodes, 0, &(&2 + Map.fetch!(&1, key)))

  defp integer_field(node, key), do: round(number_field(node, key))

  defp number_field(node, key) do
    case Map.get(node, key) do
      nil -> 0.0
      value when is_integer(value) -> value * 1.0
      value when is_float(value) -> value
    end
  end

  defp requirements(limit) do
    %{
      explain_page: env_int("BONFIRE_CLASSIC_EXPLAIN_PAGE", 1),
      exact_feed_publish_rows: env_optional_int("BONFIRE_CLASSIC_EXACT_FEED_PUBLISH_ROWS"),
      limit: limit,
      max_feed_publish_actual_rows:
        env_optional_float("BONFIRE_CLASSIC_MAX_FEED_PUBLISH_ACTUAL_ROWS"),
      max_feed_publish_heap_fetches:
        env_optional_int("BONFIRE_CLASSIC_MAX_FEED_PUBLISH_HEAP_FETCHES"),
      max_feed_publish_rows_removed_by_filter:
        env_optional_int("BONFIRE_CLASSIC_MAX_FEED_PUBLISH_ROWS_REMOVED_BY_FILTER"),
      max_cold_first_ms: env_optional_float("BONFIRE_CLASSIC_MAX_COLD_FIRST_MS"),
      max_first_ms: env_optional_float("BONFIRE_CLASSIC_MAX_FIRST_MS"),
      max_page_ms: env_optional_float("BONFIRE_CLASSIC_MAX_PAGE_MS"),
      max_page_p95_ms: env_optional_float("BONFIRE_CLASSIC_MAX_PAGE_P95_MS"),
      max_p95_ms: env_optional_float("BONFIRE_CLASSIC_MAX_P95_MS"),
      min_hidden_local_rows: env_optional_int("BONFIRE_CLASSIC_MIN_HIDDEN_LOCAL_ROWS"),
      min_visible_local_rows: env_optional_int("BONFIRE_CLASSIC_MIN_VISIBLE_LOCAL_ROWS"),
      page_count: env_int("BONFIRE_CLASSIC_REQUIRED_PAGES", 1),
      require_full_page?: System.get_env("BONFIRE_CLASSIC_REQUIRE_FULL_PAGE") == "1",
      require_no_feed_publish_seq_scan?:
        System.get_env("BONFIRE_CLASSIC_REQUIRE_NO_FEED_PUBLISH_SEQ_SCAN") == "1",
      require_no_temp_blocks?: System.get_env("BONFIRE_CLASSIC_REQUIRE_NO_TEMP_BLOCKS") == "1",
      require_target_index?: System.get_env("BONFIRE_CLASSIC_REQUIRE_TARGET_INDEX") == "1"
    }
  end

  defp timing(limit) do
    {timing_ms, result} = timed_feed(limit, nil)
    {timing_ms, edge_count(result)}
  end

  defp warmup_then_time(0, limit), do: {nil, [], timing(limit)}

  defp warmup_then_time(warmup_runs, limit) when warmup_runs > 0 do
    cold_first_timing = timing(limit)

    warmup_timings =
      if warmup_runs > 1, do: for(_ <- 1..(warmup_runs - 1), do: timing(limit)), else: []

    {cold_first_timing, warmup_timings, timing(limit)}
  end

  defp timed_feed(limit, after_cursor) do
    {micros, result} =
      :timer.tc(fn ->
        FeedActivities.feed(:local, feed_opts(limit, after_cursor))
      end)

    {micros / 1000, result}
  end

  defp feed_opts(limit, nil), do: [limit: limit, preload: false, timeout: :infinity]

  defp feed_opts(limit, after_cursor),
    do: [limit: limit, preload: false, after: after_cursor, timeout: :infinity]

  defp page_walk(limit) do
    page_count = env_int("BONFIRE_CLASSIC_REQUIRED_PAGES", 1)

    {pages, _cursor, _seen_ids} =
      Enum.reduce(1..page_count, {[], nil, MapSet.new()}, fn page, {pages, cursor, seen_ids} ->
        {timing_ms, result} = timed_feed(limit, cursor)
        ids = edge_ids(result)
        duplicate_ids = ids |> MapSet.new() |> MapSet.intersection(seen_ids) |> MapSet.to_list()

        page_result = %{
          after_cursor: cursor,
          duplicate_count: length(duplicate_ids),
          edge_count: length(ids),
          end_cursor: end_cursor(result),
          page: page,
          timing_ms: timing_ms
        }

        {[page_result | pages], page_result.end_cursor, MapSet.union(seen_ids, MapSet.new(ids))}
      end)

    Enum.reverse(pages)
  end

  defp timings(iterations, limit) do
    for _ <- 1..iterations do
      timing(limit)
    end
  end

  defp explain_after_cursor(page_walk) do
    explain_page = env_int("BONFIRE_CLASSIC_EXPLAIN_PAGE", 1)

    page_walk
    |> Enum.find(&(&1.page == explain_page))
    |> case do
      nil -> nil
      page -> page.after_cursor
    end
  end

  defp edge_count(%{edges: edges}) when is_list(edges), do: length(edges)
  defp edge_count(rows) when is_list(rows), do: length(rows)
  defp edge_count(_), do: 0

  defp edge_ids(%{edges: edges}) when is_list(edges), do: Enum.map(edges, &edge_id/1)
  defp edge_ids(rows) when is_list(rows), do: Enum.map(rows, &edge_id/1)
  defp edge_ids(_), do: []

  defp edge_id(%{activity: %{id: id}}), do: id
  defp edge_id(%{id: id}), do: id
  defp edge_id(other), do: inspect(other)

  defp end_cursor(%{page_info: %{end_cursor: cursor}}), do: cursor
  defp end_cursor(_), do: nil

  defp print_report(data) do
    timings = Enum.map(data.timings, &elem(&1, 0))
    edge_counts = Enum.map(data.timings, &elem(&1, 1))
    {first_timing, first_edge_count} = data.first_timing
    page_timings = Enum.map(data.page_walk, & &1.timing_ms)

    IO.puts("Classic-like local feed benchmark")
    IO.puts("benchmark_scope=query_only_preload_false")
    IO.puts("rows=#{data.rows}")
    IO.puts("churn_rows=#{data.churn_rows}")
    IO.puts("remote_every=#{data.remote_every}")
    IO.puts("fetcher_every=#{data.fetcher_every}")
    IO.puts("local_every=#{data.local_every || "disabled"}")
    IO.puts("hidden_local_every=#{data.hidden_local_every || "disabled"}")
    IO.puts("hidden_local_burst_rows=#{data.hidden_local_burst_rows}")
    IO.puts("limit=#{data.limit}")
    IO.puts("iterations=#{data.iterations}")
    IO.puts("warmup_runs=#{data.warmup_runs}")
    IO.puts("pagination_hard_max_limit=#{data.pagination_hard_max_limit}")
    IO.puts("fast_seed=#{data.fast_seed?}")
    IO.puts("keep_rows=#{data.keep_rows?}")
    IO.puts("vacuum_after_churn=#{data.vacuum_after_churn?}")
    IO.puts("vacuum_after_seed=#{data.vacuum_after_seed?}")
    IO.puts("seed_integrity_missing=#{inspect(data.seed_integrity)}")
    IO.puts("counts=#{inspect(data.counts)}")
    IO.puts("relation_sizes=#{inspect(data.relation_sizes)}")
    IO.puts("requirements=#{inspect(data.requirements)}")
    print_optional_timing("cold_first", data.cold_first_timing)
    IO.puts("warmup_timing_ms=#{inspect(format_timings(data.warmup_timings))}")
    IO.puts("first_edge_count=#{first_edge_count}")
    IO.puts("first_timing_ms=#{Float.round(first_timing, 2)}")
    IO.puts("edge_counts=#{inspect(edge_counts)}")
    IO.puts("timing_ms=#{inspect(Enum.map(timings, &Float.round(&1, 2)))}")
    IO.puts("median_ms=#{Float.round(percentile(timings, 0.5), 2)}")
    IO.puts("p95_ms=#{Float.round(percentile(timings, 0.95), 2)}")
    IO.puts("page_walk=#{inspect(format_page_walk(data.page_walk), limit: :infinity)}")
    IO.puts("page_max_ms=#{Float.round(Enum.max(page_timings, fn -> 0.0 end), 2)}")
    IO.puts("page_p95_ms=#{Float.round(percentile(page_timings, 0.95), 2)}")
    IO.puts("feed_publish_target_index_used=#{data.plan_flags.feed_publish_target_index_used}")
    IO.puts("feed_publish_pkey_used=#{data.plan_flags.feed_publish_pkey_used}")
    IO.puts("feed_publish_seq_scan_used=#{data.plan_flags.feed_publish_seq_scan_used}")
    IO.puts("feed_publish_plan_metrics=#{inspect(data.plan_metrics)}")
    IO.puts("indexes=#{inspect(data.index_info)}")
    IO.puts("explain_page=#{data.requirements.explain_page}")
    IO.puts("explain_begin")
    IO.puts(data.explain)
    IO.puts("explain_end")
  end

  defp format_page_walk(page_walk) do
    Enum.map(page_walk, fn page ->
      %{
        duplicate_count: page.duplicate_count,
        edge_count: page.edge_count,
        has_end_cursor: is_binary(page.end_cursor),
        page: page.page,
        timing_ms: Float.round(page.timing_ms, 2)
      }
    end)
  end

  defp print_optional_timing(_label, nil), do: :ok

  defp print_optional_timing(label, {timing_ms, edge_count}) do
    IO.puts("#{label}_edge_count=#{edge_count}")
    IO.puts("#{label}_timing_ms=#{Float.round(timing_ms, 2)}")
  end

  defp format_timings(timings) do
    Enum.map(timings, fn {timing_ms, edge_count} ->
      %{edge_count: edge_count, timing_ms: Float.round(timing_ms, 2)}
    end)
  end

  defp enforce_requirements!(data) do
    timings = Enum.map(data.timings, &elem(&1, 0))
    edge_counts = Enum.map(data.timings, &elem(&1, 1))
    {first_timing, first_edge_count} = data.first_timing
    p95 = percentile(timings, 0.95)
    page_timings = Enum.map(data.page_walk, & &1.timing_ms)
    page_max = Enum.max(page_timings, fn -> 0.0 end)
    page_p95 = percentile(page_timings, 0.95)
    feed_publish_rows = feed_publish_rows(data.counts)
    hidden_local_rows = hidden_local_rows(data.counts)
    visible_local_rows = visible_local_rows(data.counts)
    requirements = data.requirements
    cold_first_ms = timing_ms(data.cold_first_timing)
    bounded_feed_publish_index? = bounded_feed_publish_index?(data)

    []
    |> add_error(
      requirements.require_target_index? and
        not bounded_feed_publish_index?,
      "expected benchmark plan to use a bounded feed_publish index path"
    )
    |> add_error(
      requirements.require_no_feed_publish_seq_scan? and
        data.plan_flags.feed_publish_seq_scan_used,
      "expected benchmark plan not to use a sequential scan on bonfire_data_social_feed_publish"
    )
    |> add_error(
      requirements.require_no_temp_blocks? and data.plan_metrics.plan_temp_blocks != 0,
      "expected benchmark plan not to spill temp blocks, got #{data.plan_metrics.plan_temp_blocks}"
    )
    |> add_error(
      requirements.exact_feed_publish_rows &&
        feed_publish_rows != requirements.exact_feed_publish_rows,
      "expected exactly #{requirements.exact_feed_publish_rows} synthetic feed_publish rows, got #{feed_publish_rows}"
    )
    |> add_error(
      requirements.require_full_page? and first_edge_count != requirements.limit,
      "expected first run to return #{requirements.limit} edges, got #{first_edge_count}"
    )
    |> add_error(
      requirements.require_full_page? and Enum.any?(edge_counts, &(&1 != requirements.limit)),
      "expected every warm run to return #{requirements.limit} edges, got #{inspect(edge_counts)}"
    )
    |> add_error(
      requirements.require_full_page? and
        Enum.any?(data.page_walk, &(&1.edge_count != requirements.limit)),
      "expected every walked page to return #{requirements.limit} edges, got #{inspect(Enum.map(data.page_walk, & &1.edge_count))}"
    )
    |> add_error(
      Enum.any?(data.page_walk, &(&1.duplicate_count != 0)),
      "expected walked pages not to overlap, got duplicate counts #{inspect(Enum.map(data.page_walk, & &1.duplicate_count))}"
    )
    |> add_error(
      requirements.min_visible_local_rows &&
        visible_local_rows < requirements.min_visible_local_rows,
      "expected at least #{requirements.min_visible_local_rows} visible local rows, got #{visible_local_rows}"
    )
    |> add_error(
      requirements.min_hidden_local_rows &&
        hidden_local_rows < requirements.min_hidden_local_rows,
      "expected at least #{requirements.min_hidden_local_rows} hidden local rows, got #{hidden_local_rows}"
    )
    |> add_error(
      requirements.max_feed_publish_actual_rows &&
        data.plan_metrics.feed_publish_actual_rows > requirements.max_feed_publish_actual_rows,
      "expected feed_publish actual rows <= #{requirements.max_feed_publish_actual_rows}, got #{Float.round(data.plan_metrics.feed_publish_actual_rows, 2)}"
    )
    |> add_error(
      requirements.max_feed_publish_heap_fetches &&
        data.plan_metrics.feed_publish_heap_fetches > requirements.max_feed_publish_heap_fetches,
      "expected feed_publish heap fetches <= #{requirements.max_feed_publish_heap_fetches}, got #{data.plan_metrics.feed_publish_heap_fetches}"
    )
    |> add_error(
      requirements.max_feed_publish_rows_removed_by_filter &&
        data.plan_metrics.feed_publish_rows_removed_by_filter >
          requirements.max_feed_publish_rows_removed_by_filter,
      "expected feed_publish rows removed by filter <= #{requirements.max_feed_publish_rows_removed_by_filter}, got #{data.plan_metrics.feed_publish_rows_removed_by_filter}"
    )
    |> add_error(
      requirements.max_cold_first_ms && cold_first_ms > requirements.max_cold_first_ms,
      "expected cold first run <= #{requirements.max_cold_first_ms}ms, got #{Float.round(cold_first_ms, 2)}ms"
    )
    |> add_error(
      requirements.max_first_ms && first_timing > requirements.max_first_ms,
      "expected first run <= #{requirements.max_first_ms}ms, got #{Float.round(first_timing, 2)}ms"
    )
    |> add_error(
      requirements.max_p95_ms && p95 > requirements.max_p95_ms,
      "expected p95 <= #{requirements.max_p95_ms}ms, got #{Float.round(p95, 2)}ms"
    )
    |> add_error(
      requirements.max_page_p95_ms && page_p95 > requirements.max_page_p95_ms,
      "expected walked-page p95 <= #{requirements.max_page_p95_ms}ms, got #{Float.round(page_p95, 2)}ms"
    )
    |> add_error(
      requirements.max_page_ms && page_max > requirements.max_page_ms,
      "expected every walked page <= #{requirements.max_page_ms}ms, max was #{Float.round(page_max, 2)}ms"
    )
    |> case do
      [] ->
        IO.puts("requirements_status=passed")

      errors ->
        IO.puts("requirements_status=failed")
        raise Enum.join(Enum.reverse(errors), "\n")
    end
  end

  defp add_error(errors, true, message), do: [message | errors]
  defp add_error(errors, _, _message), do: errors

  defp hidden_local_rows([[_, _, hidden_local_rows, _, _, _] | _]), do: hidden_local_rows
  defp hidden_local_rows(_), do: 0

  defp visible_local_rows([[_, _, _, _, visible_local_rows, _] | _]), do: visible_local_rows
  defp visible_local_rows(_), do: 0

  defp feed_publish_rows([[_, _, _, _, _, feed_publish_rows] | _]), do: feed_publish_rows
  defp feed_publish_rows(_), do: 0

  defp bounded_feed_publish_index?(data) do
    data.plan_flags.feed_publish_target_index_used ||
      (data.plan_flags.feed_publish_pkey_used &&
         data.plan_metrics.feed_publish_actual_rows <= bounded_feed_publish_rows_limit(data))
  end

  defp bounded_feed_publish_rows_limit(data) do
    data.requirements.max_feed_publish_actual_rows || data.limit * 4
  end

  defp timing_ms({timing_ms, _edge_count}), do: timing_ms
  defp timing_ms(_), do: 0.0

  defp percentile([], _), do: 0.0

  defp percentile(values, percentile) do
    sorted = Enum.sort(values)
    index = max(ceil(length(sorted) * percentile) - 1, 0)
    Enum.at(sorted, index)
  end

  defp env_int(name, default) do
    case System.get_env(name) do
      nil -> default
      "" -> default
      value -> String.to_integer(value)
    end
  end

  defp env_optional_float(name) do
    case System.get_env(name) do
      nil ->
        nil

      "" ->
        nil

      value ->
        case Float.parse(value) do
          {float, ""} -> float
          _ -> raise "Expected #{name} to be a number, got #{inspect(value)}"
        end
    end
  end

  defp env_optional_int(name) do
    case System.get_env(name) do
      nil -> nil
      "" -> nil
      value -> String.to_integer(value)
    end
  end
end

Bonfire.ClassicFeedBenchmark.run()
