defmodule Iconify.Heroicons.QuestionMarkCircle do
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
        fill="none"
        stroke="currentColor"
        stroke-linecap="round"
        stroke-linejoin="round"
        stroke-width="1.5"
        d="M9.879 7.519c1.171-1.025 3.071-1.025 4.242 0c1.172 1.025 1.172 2.687 0 3.712c-.203.179-.43.326-.67.442c-.745.361-1.45.999-1.45 1.827v.75M21 12a9 9 0 1 1-18 0a9 9 0 0 1 18 0Zm-9 5.25h.008v.008H12v-.008Z"
      />
    </svg>
    """
  end
end
