defmodule Iconify.MaterialSymbols.CheckSmallRounded do
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
        d="m10 13.6l5.9-5.9q.275-.275.7-.275q.425 0 .7.275q.275.275.275.7q0 .425-.275.7l-6.6 6.6q-.3.3-.7.3q-.4 0-.7-.3l-2.6-2.6q-.275-.275-.275-.7q0-.425.275-.7q.275-.275.7-.275q.425 0 .7.275Z"
      />
    </svg>
    """
  end
end
