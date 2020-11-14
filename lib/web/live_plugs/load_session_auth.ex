defmodule Bonfire.Common.Web.LivePlugs.LoadSessionAuth do

  import Phoenix.LiveView
  alias Bonfire.Me.{Accounts, Users}

  def mount(%{"username" => username}, %{"account_id" => account_id}, socket),
    do: try_user(Users.get_for_session(username, account_id), account_id, socket)

  def mount(_, %{"account_id" => account_id}, socket),
    do: {:ok, assign(socket, current_user: nil, current_account: Accounts.get_for_session(account_id))}

  def mount(_, _, socket), do: try_user(nil, nil, socket)

  defp try_user({:ok, user}, account_id, socket) do
    {:ok, assign(socket, current_user: user, current_account: user.accounted.account)}
  end

  defp try_user(_, account_id, socket),
    do: {:ok, assign(socket, current_user: nil, current_account: account_id)}


end
