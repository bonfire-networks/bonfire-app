defmodule Iconify.Twemoji.MusicalNote do
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
      <path
        fill="#5DADEC"
        d="M34.209.206L11.791 2.793C10.806 2.907 10 3.811 10 4.803v18.782A7.94 7.94 0 0 0 7 23c-3.865 0-7 2.685-7 6c0 3.314 3.135 6 7 6s7-2.686 7-6V10.539l18-2.077v13.124A7.92 7.92 0 0 0 29 21c-3.865 0-7 2.685-7 6c0 3.314 3.135 6 7 6s7-2.686 7-6V1.803c0-.992-.806-1.71-1.791-1.597z"
      />
    </svg>
    """
  end
end
