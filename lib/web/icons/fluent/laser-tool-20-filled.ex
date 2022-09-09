defmodule Iconify.Fluent.LaserTool20Filled do
  use Phoenix.Component
  def render(assigns) do
    ~H"""
    <svg xmlns="http://www.w3.org/2000/svg" aria-hidden="true" role="img" class={@class} viewBox="0 0 20 20" aria-hidden="true"><path fill="currentColor" d="M3.5 2a.5.5 0 0 0-.5.5V5a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2V2.5a.5.5 0 0 0-.5-.5h-13Zm7 8h4A1.5 1.5 0 0 0 16 8.5V8H4v.5A1.5 1.5 0 0 0 5.5 10h4v2.5a.5.5 0 0 0 1 0V10ZM5 14.5a.5.5 0 0 1 .5-.5H7a.5.5 0 0 1 0 1H5.5a.5.5 0 0 1-.5-.5Zm8-.5a.5.5 0 0 0 0 1h1.5a.5.5 0 0 0 0-1H13Zm-2.5.5a.5.5 0 1 1-1 0a.5.5 0 0 1 1 0Zm0 2a.5.5 0 0 0-1 0v2a.5.5 0 0 0 1 0v-2Zm-1.646-1.354a.5.5 0 0 1 0 .708l-1.5 1.5a.5.5 0 0 1-.708-.708l1.5-1.5a.5.5 0 0 1 .708 0Zm2.292.708a.5.5 0 0 1 .708-.708l1.5 1.5a.5.5 0 0 1-.708.708l-1.5-1.5Z"/></svg>
    """
  end
end
