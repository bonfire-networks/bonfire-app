defmodule VoxPublica.Web.ConfirmEmailLive do
  use VoxPublica.Web, :live_view
  import VoxPublica.Web.ErrorHelpers
  use Phoenix.HTML

  alias VoxPublica.Accounts

  @impl true
  def mount(_params, _session, socket) do
    account = Accounts.changeset(%{})
    {:ok, assign(socket, changeset: account)}
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
