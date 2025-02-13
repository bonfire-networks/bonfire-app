if Mix.target() == :app do
  defmodule Bonfire.Desktop.WebApp do
    use GenServer

    def start_link(arg) do
      GenServer.start_link(__MODULE__, arg, name: __MODULE__)
    end

    @impl true
    def init(_) do
      {:ok, pid} = ElixirKit.start()
      ref = Process.monitor(pid)

      ElixirKit.publish("url", Bonfire.Application.endpoint_module().url())

      {:ok, %{ref: ref}}
    end

    @impl true
    def handle_info({:event, "open", url}, state) do
      url
      |> expand_desktop_url()
      |> browser_open()

      {:noreply, state}
    end

    @impl true
    def handle_info({:DOWN, ref, :process, _, :shutdown}, state) when ref == state.ref do
      System.stop()
      {:noreply, state}
    end

    @doc """
    Expands URL received from the Desktop App for opening in the browser.
    """
    def expand_desktop_url("") do
      Bonfire.Common.URIs.base_url()
    end

    def expand_desktop_url("/" <> _ = path) do
      to_string(%{Bonfire.Common.URIs.base_uri() | path: path})
    end

    def expand_desktop_url(path) when is_binary(path) do
      path
    end

    # def expand_desktop_url("file://" <> path) do
    #   notebook_open_url(path)
    # end

    # def expand_desktop_url("livebook://" <> rest) do
    #   notebook_import_url("https://#{rest}")
    # end

    @doc """
    Opens the given `url` in the browser.
    """
    def browser_open(url) do
      win_cmd_args = ["/c", "start", String.replace(url, "&", "^&")]

      cmd_args =
        case :os.type() do
          {:win32, _} ->
            {"cmd", win_cmd_args}

          {:unix, :darwin} ->
            # {"open", [url, "--args --kiosk", url]} # WIP
            {"open", [url]}

          {:unix, _} ->
            cond do
              System.find_executable("xdg-open") ->
                {"xdg-open", [url]}

              # When inside WSL
              System.find_executable("cmd.exe") ->
                {"cmd.exe", win_cmd_args}

              true ->
                nil
            end
        end

      case cmd_args do
        {cmd, args} -> System.cmd(cmd, args)
        nil -> Logger.warning("could not open the browser, no open command found in the system")
      end

      :ok
    end
  end
end
