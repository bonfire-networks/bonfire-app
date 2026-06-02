defmodule Bonfire.LightweightTestApplication do
  @moduledoc false

  use Application

  @template_root Path.expand("../../extensions/ember/priv/templates/lib", __DIR__)
  @generated_modules [
    "bonfire/bonfire.ex",
    "bonfire/localise.ex",
    "bonfire/postgres_types.ex",
    "bonfire/seeder.ex"
  ]
  @test_apps [:ecto, :db_connection, :postgrex, :ecto_sql, :phoenix_pubsub]

  def enabled?, do: System.get_env("BONFIRE_LIGHTWEIGHT_TEST_SETUP") == "1"

  def start(type, args) do
    if ui_tests?() do
      ensure_generated_modules!()
      apply(Bonfire.Application, :start, [type, args])
    else
      Supervisor.start_link([], strategy: :one_for_one, name: __MODULE__.Supervisor)
    end
  end

  def config_change(changed, new, removed) do
    if Code.ensure_loaded?(Bonfire.Application) do
      apply(Bonfire.Application, :config_change, [changed, new, removed])
    else
      :ok
    end
  end

  def setup_test! do
    maybe_start_bonfire()
    Enum.each(@test_apps, &Application.ensure_all_started/1)
    ensure_pubsub_started()
    maybe_migrate_repo()
    start_ex_unit()
  end

  def ensure_generated_modules! do
    unless Code.ensure_loaded?(Bonfire.Application) and Code.ensure_loaded?(Bonfire.Web.Endpoint) do
      @generated_modules
      |> Enum.map(&Path.join(@template_root, &1))
      |> Kernel.++(Path.wildcard(Path.join(@template_root, "bonfire/web/views/**/*.ex")))
      |> Kernel.++([
        Path.join(@template_root, "bonfire/web/router/routes.ex"),
        Path.join(@template_root, "bonfire/web/endpoint.ex"),
        Path.join(@template_root, "bonfire/web/fake_remote_endpoint.ex"),
        Path.join(@template_root, "bonfire/application.ex")
      ])
      |> Enum.each(fn file ->
        if File.exists?(file), do: Code.compile_file(file)
      end)
    end
  end

  defp ui_tests?, do: System.get_env("MIX_TEST_ONLY") == "ui"

  defp maybe_start_bonfire do
    if ui_tests?() do
      Mix.Task.run("ecto.create")
      Application.ensure_all_started(:bonfire)
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

  defp maybe_migrate_repo do
    if System.get_env("BONFIRE_LIGHTWEIGHT_TEST_MIGRATE") == "1" do
      repo = Bonfire.Common.Config.repo()

      if repo do
        Mix.Task.run("ecto.create")
        start_repo(repo)
        Mix.Task.run("ecto.migrate")
        run_extension_migrations_strict!(repo)
        Ecto.Adapters.SQL.Sandbox.mode(repo, :auto)
      end
    end
  end

  defp run_extension_migrations_strict!(repo) do
    results = EctoSparkles.Migrator.migrate_repo(repo, continue_on_error: true)
    failures = Enum.reject(results, &match?({:ok, _version, _desc}, &1))

    case failures do
      [] -> :ok
      failures -> raise "Extension migrations failed: #{inspect(failures)}"
    end
  end

  defp start_repo(repo) do
    case repo.start_link() do
      {:ok, _pid} -> :ok
      {:error, {:already_started, _pid}} -> :ok
    end
  end

  defp start_ex_unit do
    ExUnit.configure(
      timeout: 120_000,
      assert_receive_timeout: 1000,
      exclude: Bonfire.Common.RuntimeConfig.skip_test_tags(),
      capture_log: System.get_env("CAPTURE_LOG") != "no"
    )

    ExUnit.start()
  end
end
