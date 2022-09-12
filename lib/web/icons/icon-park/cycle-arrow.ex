defmodule Iconify.IconPark.CycleArrow do
  use Phoenix.Component

  def render(assigns) do
    ~H"""
    <svg
      xmlns="http://www.w3.org/2000/svg"
      aria-hidden="true"
      role="img"
      class={@class}
      viewBox="0 0 48 48"
      aria-hidden="true"
    >
      <g fill="none" stroke="#000" stroke-linecap="round" stroke-linejoin="round" stroke-width="4">
        <path d="M17 16H13C8.02944 16 4 20.0294 4 25C4 29.9706 8.02944 34 13 34C15.4758 34 17.7181 33.0003 19.3453 31.3826C20.9849 29.7525 24 25 24 25C24 25 27.0057 20.2685 28.632 18.6401C30.261 17.009 32.5127 16 35 16C39.9706 16 44 20.0294 44 25C44 29.9706 39.9706 34 35 34H31" /><path d="M35 30L31 34L35 38" /><path d="M13 12L17 16L13 20" />
      </g>
    </svg>
    """
  end
end
