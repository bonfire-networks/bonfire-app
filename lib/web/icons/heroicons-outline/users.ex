defmodule Iconify.HeroiconsOutline.Users do
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
        d="M12 4.354a4 4 0 1 1 0 5.292M15 21H3v-1a6 6 0 0 1 12 0v1Zm0 0h6v-1a6 6 0 0 0-9-5.197M13 7a4 4 0 1 1-8 0a4 4 0 0 1 8 0Z"
      />
    </svg>
    """
  end
end
