defmodule Iconify.Ph.Ladder do
  use Phoenix.Component

  def render(assigns) do
    ~H"""
    <svg
      xmlns="http://www.w3.org/2000/svg"
      aria-hidden="true"
      role="img"
      class={@class}
      viewBox="0 0 256 256"
      aria-hidden="true"
    >
      <path
        fill="currentColor"
        d="M215.5 213.3L164.5 73l9.1-25H184a8 8 0 0 0 0-16H88a8 8 0 0 0 0 16h4.6L32.5 213.3a7.9 7.9 0 0 0 4.8 10.2a8.6 8.6 0 0 0 2.7.5a7.9 7.9 0 0 0 7.5-5.3l9.7-26.7h47l-7.7 21.3a7.9 7.9 0 0 0 4.8 10.2a8.6 8.6 0 0 0 2.7.5a7.9 7.9 0 0 0 7.5-5.3L130 168h52l18.5 50.7a7.9 7.9 0 0 0 7.5 5.3a8.6 8.6 0 0 0 2.7-.5a7.9 7.9 0 0 0 4.8-10.2Zm-88-85.3h-47l11.6-32h47Zm29.1-80l-11.7 32H98l11.6-32ZM63.1 176l11.6-32h47L110 176Zm72.7-24L156 96.4l20.2 55.6Z"
      />
    </svg>
    """
  end
end
