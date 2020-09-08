defmodule VoxPublica.Web.LoginLive do
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
  def handle_event("login", attrs, socket) do
    case Accounts.login(attrs) do
      {:ok, account} ->
        {:noreply, push_redirect(assign(socket, :account, account), to: "/home")}
      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

end
