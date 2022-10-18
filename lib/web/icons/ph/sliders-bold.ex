defmodule Iconify.Ph.SlidersBold do
  use Phoenix.Component

  def render(assigns) do
    ~H"""
    <svg
      xmlns="http://www.w3.org/2000/svg"
      aria-hidden="true"
      role="img"
      class={@class}
      viewBox="0 0 256 256"
      aria-hidden="true"
    >
      <path
        fill="currentColor"
        d="M140 58.4V40a12 12 0 0 0-24 0v18.4a32 32 0 0 0 0 59.3V216a12 12 0 0 0 24 0v-98.3a32 32 0 0 0 0-59.3ZM232 168a31.9 31.9 0 0 0-20-29.6V40a12 12 0 0 0-24 0v98.4a32 32 0 0 0 0 59.3V216a12 12 0 0 0 24 0v-18.3a32.2 32.2 0 0 0 20-29.7ZM68 106.4V40a12 12 0 0 0-24 0v66.4a32 32 0 0 0 0 59.3V216a12 12 0 0 0 24 0v-50.3a32 32 0 0 0 0-59.3Z"
      />
    </svg>
    """
  end
end
