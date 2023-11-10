import Bonfire.Common.Config, only: [repo: 0]

ExUnit.configure(
  formatters: [
    ExUnit.CLIFormatter,
    ExUnitNotifier,
    Bonfire.Common.TestSummary
    # Bonfire.UI.Kanban.TestDrivenCoordination
  ]
)

# Code.put_compiler_option(:nowarn_unused_vars, true)

ExUnit.start(
  #  miliseconds
  timeout: 120_000,
  assert_receive_timeout: 1000,
  exclude: Bonfire.Common.RuntimeConfig.skip_test_tags(),
  # only show log for failed tests (Can be overridden for individual tests via `@tag capture_log: false`)
  capture_log: true
)

Mneme.start()

Mix.Task.run("ecto.create")
Mix.Task.run("ecto.migrate")

# Ecto.Adapters.SQL.Sandbox.mode(repo(), :manual)

# if System.get_env("START_SERVER") !="yes" do
Ecto.Adapters.SQL.Sandbox.mode(repo(), :auto)
# end

# ExUnit.after_suite(fn results ->
#     # do stuff
#     IO.inspect(test_results: results)

#     :ok
# end)

Application.put_env(:wallaby, :base_url, Bonfire.Web.Endpoint.url())
chromedriver_path = Bonfire.Common.Config.get([:wallaby, :chromedriver, :path])

if chromedriver_path && File.exists?(chromedriver_path),
  do: {:ok, _} = Application.ensure_all_started(:wallaby),
  else: IO.inspect("Note: Wallaby UI tests will not run because the chromedriver is missing")

# insert fixtures in test instance's repo on startup
if System.get_env("TEST_INSTANCE") == "yes",
  do: Bonfire.Common.TestInstanceRepo.apply(&Bonfire.Boundaries.Fixtures.insert/0)

IO.puts("""

Testing shows the presence, not the absence of bugs.
 - Edsger W. Dijkstra
""")

if System.get_env("OBSERVE") do
  Mix.ensure_application!(:wx)
  Mix.ensure_application!(:runtime_tools)
  Mix.ensure_application!(:observer)
  :observer.start()
end
