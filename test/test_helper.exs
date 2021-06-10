ExUnit.configure formatters: [ExUnit.CLIFormatter, ExUnitNotifier]
ExUnit.start(exclude: [:skip])

Mix.Task.run("ecto.create")
Mix.Task.run("ecto.migrate")

# Ecto.Adapters.SQL.Sandbox.mode(Bonfire.Repo, :manual)
Ecto.Adapters.SQL.Sandbox.mode(Bonfire.Repo, :auto)
