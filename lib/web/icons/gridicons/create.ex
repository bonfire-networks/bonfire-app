defmodule Iconify.Gridicons.Create do
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
        d="M21 14v5a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5v2H5v14h14v-5h2z"
      /><path fill="currentColor" d="M21 7h-4V3h-2v4h-4v2h4v4h2V9h4z" />
    </svg>
    """
  end
end
