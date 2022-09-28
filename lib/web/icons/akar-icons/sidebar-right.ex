defmodule Iconify.AkarIcons.SidebarRight do
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
      <g fill="none" stroke="currentColor" stroke-width="2">
        <rect
          width="20"
          height="18"
          x="2"
          y="3"
          stroke-linecap="round"
          stroke-linejoin="round"
          rx="2"
        /><path d="M15 3v18" />
      </g>
    </svg>
    """
  end
end
