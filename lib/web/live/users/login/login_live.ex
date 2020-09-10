defmodule VoxPublica.Web.LoginLive do
  use VoxPublica.Web, :live_view
  import VoxPublica.Web.ErrorHelpers
  use Phoenix.HTML
  import VoxPublica.Web.CommonHelper
  alias VoxPublica.Accounts
  alias VoxPublica.Accounts.LoginForm

  @impl true
  def mount(params, session, socket) do
    socket = init_assigns(params, session, socket)
    if socket.assigns[:account] do
      {:ok, push_redirect(socket, to: "/home", replace: true)}
    else
      {:ok, assign(socket, login_error: nil, changeset: LoginForm.changeset(%{}))}
    end
  end

  @impl true
  def handle_event("submit", attrs, socket) do
    case Accounts.login(attrs) do
      {:ok, account} ->
        {:noreply, push_redirect(assign(socket, :account, account), to: "/home")}
      {:error, error} when is_atom(error) ->
        {:noreply, assign(socket, login_error: error)}
      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

end
