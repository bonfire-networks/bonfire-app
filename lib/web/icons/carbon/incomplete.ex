defmodule Iconify.Carbon.Incomplete do
  use Phoenix.Component

  def render(assigns) do
    ~H"""
    <svg
      xmlns="http://www.w3.org/2000/svg"
      aria-hidden="true"
      role="img"
      class={@class}
      viewBox="0 0 32 32"
      aria-hidden="true"
    >
      <path
        fill="currentColor"
        d="m23.764 6.86l1.285-1.532a13.976 13.976 0 0 0-4.182-2.441l-.683 1.878a11.973 11.973 0 0 1 3.58 2.094zM27.81 14l1.968-.413a13.889 13.889 0 0 0-1.638-4.541L26.409 10a12.52 12.52 0 0 1 1.401 4zm-7.626 13.235l.683 1.878a13.976 13.976 0 0 0 4.182-2.44l-1.285-1.532a11.973 11.973 0 0 1-3.58 2.094zM26.409 22l1.731 1a14.14 14.14 0 0 0 1.638-4.587l-1.968-.347A12.152 12.152 0 0 1 26.409 22zM16 30V2a14 14 0 0 0 0 28z"
      />
    </svg>
    """
  end
end
