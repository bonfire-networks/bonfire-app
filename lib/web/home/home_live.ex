defmodule Bonfire.Web.HomeLive do
    use Bonfire.Web, :live_view

    alias Bonfire.Common.Web.LivePlugs

    def mount(params, session, socket) do
      LivePlugs.live_plug params, session, socket, [
        LivePlugs.LoadCurrentAccount,
        LivePlugs.LoadCurrentUser,
        LivePlugs.StaticChanged,
        LivePlugs.Csrf,
        &mounted/3,
      ]
    end

    defp mounted(params, session, socket) do
      {:ok, socket
      |> assign(page_title: "A Bonfire Instance",
      )}
    end

    # def handle_params(%{"tab" => tab} = _params, _url, socket) do
    #   {:noreply,
    #    assign(socket,
    #      selected_tab: tab
    #    )}
    # end

    # def handle_params(%{} = _params, _url, socket) do
    #   {:noreply,
    #    assign(socket,
    #      current_user: Fake.user_live()
    #    )}
    # end

  end
