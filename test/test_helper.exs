ExUnit.configure formatters: [ExUnit.CLIFormatter, ExUnitNotifier]
++ [Bonfire.Common.TestSummary]
# ++ [Bonfire.UI.Kanban.TestDrivenCoordination]

# Code.put_compiler_option(:nowarn_unused_vars, true)

skip = [:skip, :todo, :fixme]
skip = if System.get_env("TEST_INSTANCE")=="yes", do: skip, else: [:test_instance] ++ skip # skip two-instances-required federation tests
skip = if System.get_env("CI"), do: [:browser] ++ skip, else: skip # skip browser automation tests in CI
IO.inspect(skip, label: "Skipping tests tagged with")

ExUnit.start(
  exclude: skip,
  capture_log: true # only show log for failed tests (Can be overridden for individual tests via `@tag capture_log: false`)
)

# Mix.Task.run("ecto.create")
# Mix.Task.run("ecto.migrate")

# Ecto.Adapters.SQL.Sandbox.mode(Bonfire.Common.Repo, :manual)

# if System.get_env("START_SERVER") !="true" do
  Ecto.Adapters.SQL.Sandbox.mode(Bonfire.Common.Repo, :auto)
# end

# ExUnit.after_suite(fn results ->
#     # do stuff
#     IO.inspect(test_results: results)

#     :ok
# end)

Application.put_env(:wallaby, :base_url, Bonfire.Web.Endpoint.url())
chromedriver_path = Bonfire.Common.Config.get([:wallaby, :chromedriver, :path])
# TODO: skip browser-based tests if no driver is available
if chromedriver_path && File.exists?(chromedriver_path), do: {:ok, _} = Application.ensure_all_started(:wallaby), else: IO.inspect("Note: Wallaby will not run because the chromedriver is missing")
