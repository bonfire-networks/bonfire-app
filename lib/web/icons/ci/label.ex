defmodule Iconify.Ci.Label do
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
        d="m15.5 19l-11-.01a2 2 0 0 1-2-1.99V7a2 2 0 0 1 2-1.99l11-.01a2 2 0 0 1 1.63.84L21.5 12l-4.37 6.16a2 2 0 0 1-1.63.84ZM4.5 7v10h11l3.55-5l-3.55-5h-11Z"
      />
    </svg>
    """
  end
end
