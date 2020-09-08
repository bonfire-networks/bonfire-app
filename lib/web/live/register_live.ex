defmodule VoxPublica.Web.RegisterLive do
  use VoxPublica.Web, :live_view
  import VoxPublica.Web.ErrorHelpers
  use Phoenix.HTML

  alias VoxPublica.Accounts

  @impl true
  def mount(_params, _session, socket) do
    if socket.assigns[:account] do
      {:ok, assign(socket, changeset: Accounts.changeset(%{}))}
    else
      {:ok, push_redirect(socket, to: "/home", replace: true)}
    end
  end

  @impl true
  def handle_event("validate", params, socket) do
    {:noreply, assign(socket, changeset: Accounts.changeset(params))}
  end

  @impl true
  def handle_event("submit", _params, socket) do
    
    # else
      {:noreply, socket} #assign(socket, results: search(query), query: query)}
    # end

  end

end
