defmodule Iconify.Ep.RemoveFilled do
  use Phoenix.Component

  def render(assigns) do
    ~H"""
    <svg
      xmlns="http://www.w3.org/2000/svg"
      aria-hidden="true"
      role="img"
      class={@class}
      viewBox="0 0 1024 1024"
      aria-hidden="true"
    >
      <path
        fill="currentColor"
        d="M512 64a448 448 0 1 1 0 896a448 448 0 0 1 0-896zM288 512a38.4 38.4 0 0 0 38.4 38.4h371.2a38.4 38.4 0 0 0 0-76.8H326.4A38.4 38.4 0 0 0 288 512z"
      />
    </svg>
    """
  end
end
