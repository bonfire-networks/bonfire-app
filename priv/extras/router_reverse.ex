# if Bonfire.Common.Config.get(:env) !=:prod do
#   IO.puts("Re-compile routes to toggle paths of enabled/disabled extensions...")
#   defmodule Bonfire.Web.Router do
#     use Bonfire.Web.Router.Routes #, generate_open_api: true
#   end
# end

defmodule Bonfire.Web.Router.Reverse do
  import Voodoo, only: [def_reverse_router: 2]
  def_reverse_router(:path, for: Bonfire.Web.Router, filter: [module: Bonfire.Common.Extend, fun: :module_exists?])
end
