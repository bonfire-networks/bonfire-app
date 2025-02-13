if System.get_env("AS_DESKTOP_APP") in ["1", "true"] do
  defmodule Bonfire.Desktop.MenuBar do
    @moduledoc """
      Menu bar that is shown as part of the main Window on Windows/Linux. In
      MacOS this Menubar appears at the very top of the screen.
    """
    use Desktop.Menu
    use Bonfire.Common.Localise
    alias Desktop.Window

    def render(assigns) do
      ~H"""
      <menubar>
        <menu label={l("File")}>
          <%!-- <%= for item <- @todos do %>
          <item
              type="checkbox" onclick={"toggle:#{item.id}"}
              checked={item.status == "done"}
              ><%= item.text %></item>
          <% end %> --%>
          <hr />
          <item onclick="quit">{l("Quit")}</item>
        </menu>
        <menu label={l("Extra")}>
          <item onclick="notification">{l("Show Notification")}</item>
          <item onclick="observer">{l("Show Observer")}</item>
          <item onclick="browser">{l("Open Browser")}</item>
        </menu>
      </menubar>
      """
    end

    #   def handle_event(<<"toggle:", id::binary>>, menu) do
    #     Todo.toggle_todo(String.to_integer(id))
    #     {:noreply, menu}
    #   end

    def handle_event("observer", menu) do
      :observer.start()
      {:noreply, menu}
    end

    def handle_event("quit", menu) do
      Window.quit()
      {:noreply, menu}
    end

    def handle_event("browser", menu) do
      Window.prepare_url(Bonfire.Desktop.Endpoint.url())
      |> :wx_misc.launchDefaultBrowser()

      {:noreply, menu}
    end

    def handle_event("notification", menu) do
      Window.show_notification(
        Bonfire,
        # , callback: &TodoWeb.TodoLive.notification_event/1
        l("Sample Elixir Desktop App!")
      )

      {:noreply, menu}
    end

    def mount(menu) do
      # TodoApp.Todo.subscribe()
      {
        :ok,
        menu
        # |> assign(todos: Todo.all_todos())
      }
    end

    def handle_info(:changed, menu) do
      {
        :noreply,
        menu
        # |> assign(todos: Todo.all_todos())
      }
    end
  end
end
