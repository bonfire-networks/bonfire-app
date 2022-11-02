defmodule Iconify.Carbon.AirlinePassengerCare do
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
        d="M18 23h-2v-2a3.003 3.003 0 0 0-3-3H9a3.003 3.003 0 0 0-3 3v2H4v-2a5.006 5.006 0 0 1 5-5h4a5.006 5.006 0 0 1 5 5zM11 6a3 3 0 1 1-3 3a3 3 0 0 1 3-3m0-2a5 5 0 1 0 5 5a5 5 0 0 0-5-5zM2 26h28v2H2zM27.303 8a2.662 2.662 0 0 0-1.908.806L25 9.21l-.395-.405a2.662 2.662 0 0 0-3.816 0a2.8 2.8 0 0 0 0 3.896L25 17l4.21-4.298a2.8 2.8 0 0 0 0-3.896A2.662 2.662 0 0 0 27.304 8z"
      />
    </svg>
    """
  end
end
