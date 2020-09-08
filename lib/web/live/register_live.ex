defmodule VoxPublica.Web.RegisterLive do
  use VoxPublica.Web, :live_view
  import VoxPublica.Web.ErrorHelpers
  use Phoenix.HTML

  alias VoxPublica.Accounts
  alias VoxPublica.Accounts.RegisterForm

  @impl true
  def mount(_params, _session, socket) do
    if socket.assigns[:account] do
      {:ok, push_redirect(socket, to: "/home", replace: true)}
    else
      {:ok, assign(socket, registered: false, register_error: nil, changeset: RegisterForm.changeset(%{}))}
    end
  end


  @impl true
  def handle_event("submit", params, socket) do
    case Accounts.register(params) do
      {:ok, account} ->
        {:noreply, assign(socket, registered: true, register_error: nil)}
      {:error, :taken} ->
        {:noreply, assign(socket, register_error: :taken)}
      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

end
