defmodule Iconify.HeroiconsOutline.QuestionMarkCircle do
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
        d="M8.228 9c.549-1.165 2.03-2 3.772-2c2.21 0 4 1.343 4 3c0 1.4-1.278 2.575-3.006 2.907c-.542.104-.994.54-.994 1.093m0 3h.01M21 12a9 9 0 1 1-18 0a9 9 0 0 1 18 0Z"
      />
    </svg>
    """
  end
end
