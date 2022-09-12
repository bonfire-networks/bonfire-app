defmodule Iconify.Twemoji.Newspaper do
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
      <path fill="#99AAB5" d="M33 36H4c4 0 3-9 3-9c0-2.209 1.791-15 4-15h21s4 0 4 4v17s0 3-3 3z" /><path
        fill="#CCD6DD"
        d="M30 33c0 3 3 3 3 3H3s-3 0-3-4V4a4 4 0 0 1 4-4h22a4 4 0 0 1 4 4v29z"
      /><path
        fill="#99AAB5"
        d="M27 20a1 1 0 0 1-1 1h-8a1 1 0 1 1 0-2h8a1 1 0 0 1 1 1zm0-4a1 1 0 0 1-1 1h-8a1 1 0 1 1 0-2h8a1 1 0 0 1 1 1zm0-4a1 1 0 0 1-1 1h-8a1 1 0 1 1 0-2h8a1 1 0 0 1 1 1zm0 12a1 1 0 0 1-1 1H4a1 1 0 1 1 0-2h22a1 1 0 0 1 1 1zm0 4a1 1 0 0 1-1 1H4a1 1 0 1 1 0-2h22a1 1 0 0 1 1 1zm0 4a1 1 0 0 1-1 1H4a1 1 0 1 1 0-2h22a1 1 0 0 1 1 1zM25 9s2 0 2-2V5s0-2-2-2H5S3 3 3 5v2s0 2 2 2h20z"
      /><path fill="#55ACEE" d="M13 21s2 0 2-2v-6s0-2-2-2H5s-2 0-2 2v6s0 2 2 2h8z" />
    </svg>
    """
  end
end
