defmodule Iconify.HeroiconsSolid.MinusCircle do
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
        d="M10 18a8 8 0 1 0 0-16a8 8 0 0 0 0 16ZM7 9a1 1 0 0 0 0 2h6a1 1 0 1 0 0-2H7Z"
        clip-rule="evenodd"
      />
    </svg>
    """
  end
end
