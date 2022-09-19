defmodule Iconify.Twemoji.ShintoShrine do
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
        fill="#DD2E44"
        d="M9 9a2 2 0 0 0-4 0v24a2 2 0 0 0 4 0V9zm22 0a2 2 0 0 0-4 0v24a2 2 0 0 0 4 0V9z"
      /><path
        fill="#DD2E44"
        d="M36 16a2 2 0 0 1-2 2H2a2 2 0 0 1 0-4h32a2 2 0 0 1 2 2zm-1-9c0 1.104-.781 1.719-2 2c0 0-3 1-15 1S3 9 3 9c-1.266-.266-2-.896-2-2s.896-2 2-2h30a2 2 0 0 1 2 2z"
      /><path
        fill="#292F33"
        d="M35.906 4c0 1.104-.659 1.797-1.908 2c0 0-4 1-15.999 1C6.001 7 2.002 6 2.002 6C.831 5.812.109 5.114.109 4.01C.109 2.905-.102 1 1.002 1c0 0 3.999 2 16.997 2s16.998-2 16.998-2c1.105 0 .909 1.895.909 3z"
      /><path fill="#DD2E44" d="M20 15a2 2 0 0 1-4 0V9a2 2 0 0 1 4 0v6z" /><path
        fill="#292F33"
        d="M11 34a2 2 0 0 1-2 2H5a2 2 0 0 1 0-4h4a2 2 0 0 1 2 2zm22 0a2 2 0 0 1-2 2h-4a2 2 0 0 1 0-4h4a2 2 0 0 1 2 2z"
      />
    </svg>
    """
  end
end
