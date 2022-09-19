defmodule Iconify.Twemoji.Clipboard do
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
        fill="#C1694F"
        d="M32 34a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V7a2 2 0 0 1 2-2h24a2 2 0 0 1 2 2v27z"
      /><path
        fill="#FFF"
        d="M29 32a1 1 0 0 1-1 1H8a1 1 0 0 1-1-1V9a1 1 0 0 1 1-1h20a1 1 0 0 1 1 1v23z"
      /><path fill="#CCD6DD" d="M25 3h-4a3 3 0 1 0-6 0h-4a2 2 0 0 0-2 2v5h18V5a2 2 0 0 0-2-2z" /><circle
        cx="18"
        cy="3"
        r="2"
        fill="#292F33"
      /><path
        fill="#99AAB5"
        d="M20 14a1 1 0 0 1-1 1h-9a1 1 0 0 1 0-2h9a1 1 0 0 1 1 1zm7 4a1 1 0 0 1-1 1H10a1 1 0 0 1 0-2h16a1 1 0 0 1 1 1zm0 4a1 1 0 0 1-1 1H10a1 1 0 1 1 0-2h16a1 1 0 0 1 1 1zm0 4a1 1 0 0 1-1 1H10a1 1 0 1 1 0-2h16a1 1 0 0 1 1 1zm0 4a1 1 0 0 1-1 1h-9a1 1 0 1 1 0-2h9a1 1 0 0 1 1 1z"
      />
    </svg>
    """
  end
end
