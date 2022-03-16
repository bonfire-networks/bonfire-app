# if Code.ensure_loaded?(ExSync) && function_exported?(ExSync, :register_group_leader, 0) do
#   ExSync.register_group_leader()
# end

alias Bonfire.Repo
alias Bonfire.Data
alias Bonfire.Me
alias Bonfire.Social
alias Bonfire.Common
use Common.Utils
import Bonfire.Me.Fake
require Logger

if module_enabled?(Bonfire.Common.Test.Interactive) do
  # to run tests from iex

  # Code.compiler_options(ignore_module_conflict: true)
  # Code.compile_file("~/.iex/iex_watch_tests.exs", File.cwd!())

  unless GenServer.whereis(Bonfire.Common.Test.Interactive) do
    {:ok, pid} = Bonfire.Common.Test.Interactive.start_link()

    # Process will not exit when the iex goes out
    Process.unlink(pid)
  end

  Bonfire.Common.Test.Interactive.Helpers.ready

else
  Logger.info("IExWatchTests is not available")
end
import_if_enabled Bonfire.Common.Test.Interactive.Helpers
