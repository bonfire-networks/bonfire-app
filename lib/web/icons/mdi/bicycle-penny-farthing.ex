defmodule Iconify.Mdi.BicyclePennyFarthing do
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
        d="M15.5 5.06V2H12v2h1.5v1.04c-.79.07-1.56.23-2.3.46c-.17-.3-.48-.5-.84-.5H7c-.55 0-1 .45-1 1s.45 1 1 1h1.05A11.5 11.5 0 0 0 3 16.18c-1.15.41-2 1.51-2 2.82c0 1.66 1.34 3 3 3s3-1.34 3-3c0-1.3-.83-2.39-2-2.81c.07-1.52.46-2.94 1.14-4.19c-.09.5-.14 1-.14 1.5c0 4.69 3.81 8.5 8.5 8.5c4.69 0 8.5-3.81 8.5-8.5c0-4.36-3.28-7.94-7.5-8.44M4 20c-.55 0-1-.45-1-1s.45-1 1-1s1 .45 1 1s-.45 1-1 1m10.5 0C10.92 20 8 17.08 8 13.5c0-3.24 2.39-5.93 5.5-6.41V15h2V7.09c3.11.48 5.5 3.17 5.5 6.41c0 3.58-2.92 6.5-6.5 6.5Z"
      />
    </svg>
    """
  end
end
