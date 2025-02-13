if System.get_env("AS_DESKTOP_APP") in ["1", "true"] do
  defmodule Bonfire.Desktop.TaskMenu do
    @moduledoc """
      Menu that is shown when a user click on the taskbar icon of the app
    """
    use Desktop.Menu
    use Bonfire.Common.Localise

    def handle_event(command, menu) do
      case command do
        #   <<"toggle:", id::binary>> -> TodoApp.Todo.toggle_todo(String.to_integer(id))
        <<"quit">> -> Desktop.Window.quit()
        <<"edit">> -> Desktop.Window.show(Bonfire)
      end

      {:noreply, menu}
    end

    def mount(menu) do
      # TodoApp.Todo.subscribe()
      # menu = assign(menu, todos: TodoApp.Todo.all_todos())
      # set_state_icon(menu)
      {:ok, menu}
    end

    def handle_info(:changed, menu) do
      # menu = assign(menu, todos: TodoApp.Todo.all_todos())
      # set_state_icon(menu)

      {:noreply, menu}
    end

    #   defp set_state_icon(menu) do
    #     if all_done?(menu.assigns.todos) do
    #       Menu.set_icon(menu, {:file, "icon32x32-done.png"})
    #     else
    #       Menu.set_icon(menu, {:file, "icon32x32.png"})
    #     end
    #   end
  end
end
