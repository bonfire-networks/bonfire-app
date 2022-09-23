defmodule Iconify.HeroiconsOutline.DotsVertical do
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
        stroke-linejoin="round"
        stroke-width="2"
        d="M12 5v.01M12 12v.01M12 19v.01M12 6a1 1 0 1 1 0-2a1 1 0 0 1 0 2Zm0 7a1 1 0 1 1 0-2a1 1 0 0 1 0 2Zm0 7a1 1 0 1 1 0-2a1 1 0 0 1 0 2Z"
      />
    </svg>
    """
  end
end
