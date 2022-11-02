defmodule Iconify.AkarIcons.TextAlignLeft do
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
      <path
        fill="none"
        stroke="currentColor"
        stroke-linecap="round"
        stroke-width="2"
        d="M3 6h18M3 12h10M3 18h15"
      />
    </svg>
    """
  end
end
