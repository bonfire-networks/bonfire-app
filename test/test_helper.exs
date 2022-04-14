ExUnit.configure formatters: [ExUnit.CLIFormatter, ExUnitNotifier]
++ [Bonfire.Common.TestSummary]
# ++ [Bonfire.UI.Kanban.TestDrivenCoordination]

skip = [:skip, :todo, :fixme]

skip = if System.get_env("TEST_INSTANCE")=="yes", do: skip, else: skip ++ [:test_instance]

ExUnit.start(exclude: skip)

# Mix.Task.run("ecto.create")
# Mix.Task.run("ecto.migrate")

# Ecto.Adapters.SQL.Sandbox.mode(Bonfire.Repo, :manual)

# if System.get_env("START_SERVER") !="true" do
  Ecto.Adapters.SQL.Sandbox.mode(Bonfire.Repo, :auto)
# end

# ExUnit.after_suite(fn results ->
#     # do stuff
#     IO.inspect(test_results: results)

#     :ok
# end)
