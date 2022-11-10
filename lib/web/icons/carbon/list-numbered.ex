defmodule Iconify.Carbon.ListNumbered do
  use Phoenix.Component

  def render(assigns) do
    ~H"""
    <svg
      xmlns="http://www.w3.org/2000/svg"
      aria-hidden="true"
      role="img"
      class={@class}
      viewBox="0 0 32 32"
      aria-hidden="true"
    >
      <path
        fill="currentColor"
        d="M16 22h14v2H16zm0-14h14v2H16zm-8 4V4H6v1H4v2h2v5H4v2h6v-2H8zm2 16H4v-4a2 2 0 0 1 2-2h2v-2H4v-2h4a2 2 0 0 1 2 2v2a2 2 0 0 1-2 2H6v2h4z"
      />
    </svg>
    """
  end
end
