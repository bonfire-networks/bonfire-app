defmodule VoxPublica.Web.SignupLive do
  use VoxPublica.Web, :live_view
  alias VoxPublica.Accounts
  alias VoxPublica.Accounts.SignupForm
  import VoxPublica.Web.CommonHelper

  @impl true
  def mount(params, session, socket) do
    socket = init_assigns(params, session, socket)
    if socket.assigns[:account] do
      {:ok, push_redirect(socket, to: "/home", replace: true)}
    else
      {:ok, assign(socket, registered: false, register_error: nil, changeset: SignupForm.changeset(%{}))}
    end
  end


  @impl true
  def handle_event("submit", params, socket) do
    case Accounts.signup(Map.get(params, "signup_form", %{})) do
      {:ok, _account} ->
        {:noreply, assign(socket, registered: true, register_error: nil)}
      {:error, :taken} ->
        {:noreply, assign(socket, register_error: :taken)}
      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

end
