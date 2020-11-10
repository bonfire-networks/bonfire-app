defmodule Bonfire.Web.LivePlugs do
  @moduledoc "Like a plug, but for a liveview"

  @compile {:inline, live_plug_: 4}

  def live_plug(params, session, socket, list),
    do: live_plug_(list, {:ok, socket}, params, session)

  defp live_plug_([], ret, _, _), do: ret

  defp live_plug_(_, {:halt, socket}, _, _), do: {:ok, socket}

  defp live_plug_([{mod, fun, args} | y], {:ok, socket}, params, session)
  when is_atom(mod) and is_atom(fun) and is_list(args),
    do: live_plug_(y, apply(mod, fun, [params, session, socket | args]), params, session)

  defp live_plug_([{mod, fun} | y], {:ok, socket}, params, session) when is_atom(mod) and is_atom(fun),
    do: live_plug_(y, apply(mod, fun, [params, session, socket]), params, session)

  defp live_plug_([{mod, args} | y], {:ok, socket}, params, session) when is_atom(mod) and is_list(args),
    do: live_plug_(y, apply(mod, :mount, [params, session, socket | args]), params, session)

  defp live_plug_([mod | y], {:ok, socket}, params, session) when is_atom(mod),
    do: live_plug_(y, apply(mod, :mount, [params, session, socket]), params, session)

  defp live_plug_([fun | y], {:ok, socket}, params, session) when is_function(fun,3),
    do: live_plug_(y, apply(fun, [params, session, socket]), params, session)

  defp live_plug_([{fun, args} | y], {:ok, socket}, params, session)
  when is_list(args) and is_function(fun),
    do: live_plug_(y, apply(fun, [params, session, socket]), params, session)

  defp live_plug_(_, other, _, _), do: other

end
