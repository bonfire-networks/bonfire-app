defmodule Iconify.Majesticons.ViewColumns do
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
        fill-rule="evenodd"
        d="M7 5H5a3 3 0 0 0-3 3v8a3 3 0 0 0 3 3h2V5zm2 14h6V5H9v14zm8-14v14h2a3 3 0 0 0 3-3V8a3 3 0 0 0-3-3h-2z"
        clip-rule="evenodd"
      />
    </svg>
    """
  end
end
