defmodule Iconify.Gg.MenuLeftAlt do
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
        d="M4 6a1 1 0 0 1 1-1h14a1 1 0 1 1 0 2H5a1 1 0 0 1-1-1Zm0 12a1 1 0 0 1 1-1h14a1 1 0 1 1 0 2H5a1 1 0 0 1-1-1Zm1-7a1 1 0 1 0 0 2h8a1 1 0 1 0 0-2H5Z"
      />
    </svg>
    """
  end
end
