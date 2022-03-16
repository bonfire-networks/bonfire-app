ExUnit.configure formatters: [ExUnit.CLIFormatter, ExUnitNotifier]
++ [Bonfire.Common.TestSummary]
# ++ [Bonfire.UI.Kanban.TestDrivenCoordination]

ExUnit.start(exclude: [:skip, :todo, :fixme])

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
