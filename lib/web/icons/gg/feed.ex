defmodule Iconify.Gg.Feed do
  use Phoenix.Component

  def render(assigns) do
    ~H"""
    <svg
      xmlns="http://www.w3.org/2000/svg"
      aria-hidden="true"
      role="img"
      class={@class}
      viewBox="0 0 24 24"
      aria-hidden="true"
    >
      <g fill="currentColor">
        <path
          fill-opacity=".5"
          d="M12.552 8a1 1 0 1 0 0 2h4a1 1 0 1 0 0-2h-4Zm0 9a1 1 0 1 0 0 2h4a1 1 0 1 0 0-2h-4Z"
        /><path
          fill-opacity=".8"
          d="M12.552 5a1 1 0 1 0 0 2h8a1 1 0 1 0 0-2h-8Zm0 9a1 1 0 1 0 0 2h8a1 1 0 1 0 0-2h-8Z"
        /><path d="M3.448 4.002a1 1 0 0 0-1 1v5a1 1 0 0 0 1 1h5a1 1 0 0 0 1-1v-5a1 1 0 0 0-1-1h-5Zm0 8.996a1 1 0 0 0-1 1v5a1 1 0 0 0 1 1h5a1 1 0 0 0 1-1v-5a1 1 0 0 0-1-1h-5Z" />
      </g>
    </svg>
    """
  end
end
