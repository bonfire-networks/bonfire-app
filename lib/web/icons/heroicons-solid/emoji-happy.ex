defmodule Iconify.HeroiconsSolid.EmojiHappy do
  use Phoenix.Component

  def render(assigns) do
    ~H"""
    <svg
      xmlns="http://www.w3.org/2000/svg"
      aria-hidden="true"
      role="img"
      class={@class}
      viewBox="0 0 20 20"
      aria-hidden="true"
    >
      <path
        fill="currentColor"
        fill-rule="evenodd"
        d="M10 18a8 8 0 1 0 0-16a8 8 0 0 0 0 16ZM7 9a1 1 0 1 0 0-2a1 1 0 0 0 0 2Zm7-1a1 1 0 1 1-2 0a1 1 0 0 1 2 0Zm-.464 5.535a1 1 0 1 0-1.415-1.414a3 3 0 0 1-4.242 0a1 1 0 0 0-1.415 1.414a5 5 0 0 0 7.072 0Z"
        clip-rule="evenodd"
      />
    </svg>
    """
  end
end
