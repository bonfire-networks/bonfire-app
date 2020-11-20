defmodule Bonfire.Web.Hax do

  alias Plug.Conn
  alias Phoenix.Controller
  alias Phoenix.View

  def render_live_view(%Conn{}=conn, module, assigns \\ [])
  when is_atom(module) and is_list(assigns) do
    module.render(assigns).static
    |> layout(Controller.layout(conn), assigns)
    |> layout(Controller.root_layout(conn), assigns)
  end

  defp layout(inner, {mod, tpl}, assigns) do
    tpl = Atom.to_string(tpl) <> ".html"
    assigns = Map.delete(Map.put(assigns, :inner_content, inner), :layout)
    View.render_to_iodata(mod, tpl, assigns)
  end

end
