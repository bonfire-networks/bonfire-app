defmodule Iconify.EosIcons.Pin do
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
        fill="currentColor"
        d="M18.27 9.81h-2.82L9.77 4.13l.71-.71l-1.42-1.41l-7.07 7.07l1.42 1.41l.71-.71l5.67 5.68h-.01v2.83l1.42 1.42l3.54-3.55l4.77 4.77l1.41-1.41l-4.77-4.77l3.53-3.53l-1.41-1.41z"
      />
    </svg>
    """
  end
end
