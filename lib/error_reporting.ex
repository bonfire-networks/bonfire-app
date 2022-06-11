defmodule Bonfire.ErrorReporting do
  @behaviour Plug
  import Where

  defmacro __using__(_) do
    quote do
      require Bonfire.Common.Extend
      Bonfire.Common.Extend.use_if_enabled Sentry.PlugCapture
    end
  end

  @impl true
  def init(_opts) do
    []
  end

  @impl true
  def call(conn, opts) do
    if Bonfire.Common.Extend.module_enabled?(Sentry), do: Sentry.PlugContext.call(conn, opts), else: conn
  end

end
