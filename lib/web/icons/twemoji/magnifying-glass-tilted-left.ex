defmodule Iconify.Twemoji.MagnifyingGlassTiltedLeft do
  use Phoenix.Component

  def render(assigns) do
    ~H"""
    <svg
      xmlns="http://www.w3.org/2000/svg"
      aria-hidden="true"
      role="img"
      class={@class}
      viewBox="0 0 36 36"
      aria-hidden="true"
    >
      <path fill="#9AAAB4" d="M27.388 24.642L24.56 27.47l-4.95-4.95l2.828-2.828z" /><path
        fill="#66757F"
        d="m34.683 29.11l-5.879-5.879a2 2 0 0 0-2.828 0l-2.828 2.828a2 2 0 0 0 0 2.828l5.879 5.879a4 4 0 1 0 5.656-5.656z"
      /><circle cx="13.586" cy="13.669" r="13.5" fill="#8899A6" /><circle
        cx="13.586"
        cy="13.669"
        r="9.5"
        fill="#BBDDF5"
      />
    </svg>
    """
  end
end
