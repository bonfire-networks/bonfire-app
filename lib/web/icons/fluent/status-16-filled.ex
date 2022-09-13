defmodule Iconify.Fluent.Status16Filled do
  use Phoenix.Component

  def render(assigns) do
    ~H"""
    <svg
      xmlns="http://www.w3.org/2000/svg"
      aria-hidden="true"
      role="img"
      class={@class}
      viewBox="0 0 16 16"
      aria-hidden="true"
    >
      <path
        fill="currentColor"
        d="M14.354 1.647a2.268 2.268 0 0 0-3.207 0l-4.25 4.25a.5.5 0 0 0-.121.195l-1.25 3.75a.5.5 0 0 0 .632.633l3.75-1.25a.5.5 0 0 0 .196-.121l4.25-4.25a2.268 2.268 0 0 0 0-3.207Zm-1.367 5.988a5 5 0 1 1-4.621-4.621l.883-.884a6 6 0 1 0 4.621 4.621l-.883.884Z"
      />
    </svg>
    """
  end
end
