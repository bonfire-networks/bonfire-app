defmodule Iconify.Mdi.BulletinBoard do
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
        d="M12.04 2.5L9.53 5h5l-2.49-2.5M4 7v13h16V7H4m8-7l5 5h3a2 2 0 0 1 2 2v13a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V7a2 2 0 0 1 2-2h3l5-5M7 18v-4h5v4H7m7-1v-7h4v7h-4m-8-5V9h5v3H6Z"
      />
    </svg>
    """
  end
end
