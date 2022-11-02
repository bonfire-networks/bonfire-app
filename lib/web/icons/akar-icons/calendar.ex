defmodule Iconify.AkarIcons.Calendar do
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
      <g
        fill="none"
        stroke="currentColor"
        stroke-linecap="round"
        stroke-linejoin="round"
        stroke-width="2"
      >
        <rect width="20" height="18" x="2" y="4" rx="4" /><path d="M8 2v4m8-4v4M2 10h20" />
      </g>
    </svg>
    """
  end
end
