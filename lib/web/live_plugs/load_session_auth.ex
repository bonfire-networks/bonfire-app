defmodule Bonfire.Web.LivePlugs.LoadSessionAuth do

  import Phoenix.LiveView
  alias Bonfire.{Accounts, Users}

  def mount(%{"username" => username}, %{"account_id" => id}, socket),
    do: try_user(Users.get_for_session(username, id), socket)

  def mount(_, %{"account_id" => id}, socket),
    do: {:ok, assign(socket, current_user: nil, current_account: Accounts.get_for_session(id))}

  def mount(_, _, socket), do: try_user(nil, socket)

  defp try_user(nil, socket),
    do: {:ok, assign(socket, current_user: nil, current_account: nil)}

  defp try_user(user, socket),
    do: {:ok, assign(socket, current_user: user, current_account: user.accounted.account)}

end
