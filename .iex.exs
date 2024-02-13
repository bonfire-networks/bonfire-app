# if Code.ensure_loaded?(ExSync) && function_exported?(ExSync, :register_group_leader, 0) do
#   ExSync.register_group_leader()
# end

use ConsoleHelpers

# if module_enabled?(Bonfire.Common.Test.Interactive) and Mix.env() == :test do
#   # to run tests from iex

#   # Code.compiler_options(ignore_module_conflict: true)
#   # Code.compile_file("~/.iex/iex_watch_tests.exs", File.cwd!())

#   unless GenServer.whereis(Bonfire.Common.Test.Interactive) do
#     {:ok, pid} = Bonfire.Common.Test.Interactive.start_link()

#     # Process will not exit when the iex goes out
#     Process.unlink(pid)
#   end

#   Bonfire.Common.Test.Interactive.Helpers.ready()
# else
#   if Mix.env() == :test, do: info("IExWatchTests is not running")
# end

# import_if_enabled(Bonfire.Common.Test.Interactive.Helpers)


# if Code.ensure_loaded?(ExSync) and function_exported?(ExSync, :register_group_leader, 0) do
#   ExSync.register_group_leader()
# end


defmodule ObserverCLI do
  def observer_cli_start, do: start()
  defp start do
    Logger.configure(level: :error)
    :observer_cli.start
  end
end
import ObserverCLI
