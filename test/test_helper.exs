ExUnit.configure formatters: [ExUnit.CLIFormatter, ExUnitNotifier]
# ExUnit.configure formatters: [ExUnit.CLIFormatter, ExUnitNotifier, Bonfire.UI.Coordination.TestDrivenCoordination]
ExUnit.start(exclude: [:skip, :todo, :fixme])

Mix.Task.run("ecto.create")
Mix.Task.run("ecto.migrate")

# Ecto.Adapters.SQL.Sandbox.mode(Bonfire.Repo, :manual)
Ecto.Adapters.SQL.Sandbox.mode(Bonfire.Repo, :auto)

ExUnit.after_suite(fn results ->
    # do stuff
    IO.inspect(test_results: results)

    :ok
end)
