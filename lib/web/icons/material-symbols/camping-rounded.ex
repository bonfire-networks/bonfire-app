defmodule Iconify.MaterialSymbols.CampingRounded do
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
        d="M2 21v-3q0-.325.1-.625t.3-.575l8.35-11.25L9.6 4q-.125-.175-.175-.363q-.05-.187-.025-.375q.025-.187.125-.362t.275-.3q.35-.25.75-.2q.4.05.65.4l.8 1.075l.8-1.075q.25-.35.65-.4q.4-.05.75.2t.4.65q.05.4-.2.75l-1.15 1.55L21.6 16.8q.2.275.3.575q.1.3.1.625v3q0 .425-.288.712Q21.425 22 21 22H3q-.425 0-.712-.288Q2 21.425 2 21Zm6.225-1h7.55L12 14.725Z"
      />
    </svg>
    """
  end
end
