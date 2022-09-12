defmodule Iconify.IconParkOutline.CycleOne do
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
      <path
        fill="none"
        stroke="currentColor"
        stroke-linecap="round"
        stroke-linejoin="round"
        stroke-width="4"
        d="M6 20c0-8 4-12 12-12m22 22c0 8-4 12-12 12m0-24c0-5.523 4.477-10 10-10h4v14H28v-4ZM6 28h14v4c0 5.523-4.477 10-10 10H6V28Z"
      />
    </svg>
    """
  end
end
