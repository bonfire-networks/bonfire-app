defmodule VoxPublica.Web.ConfirmEmailLive do

  use VoxPublica.Web, :live_view
  alias VoxPublica.Accounts

  @impl true
  def mount(%{token: token}, _session, socket) do
    case Accounts.confirm_email(token) do
      {:ok, account} ->
        {:ok, push_redirect(socket, to: "/home", replace: true)}
        
    end
    {:ok, socket} #assign(socket, changeset: account)}
  end

  @impl true
  def handle_event("validate", _params, socket) do
    {:noreply, socket} #assign(socket, results: search(query), query: query)}
  end

  @impl true
  def handle_event("submit", _params, socket) do
    {:noreply, socket} #assign(socket, results: search(query), query: query)}
  end

end
