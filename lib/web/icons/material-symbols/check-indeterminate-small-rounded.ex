defmodule Iconify.MaterialSymbols.CheckIndeterminateSmallRounded do
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
        d="M8 13q-.425 0-.713-.288Q7 12.425 7 12t.287-.713Q7.575 11 8 11h8q.425 0 .712.287q.288.288.288.713t-.288.712Q16.425 13 16 13Z"
      />
    </svg>
    """
  end
end
