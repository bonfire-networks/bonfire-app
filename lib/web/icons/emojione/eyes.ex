defmodule Iconify.Emojione.Eyes do
  use Phoenix.Component

  def render(assigns) do
    ~H"""
    <svg
      xmlns="http://www.w3.org/2000/svg"
      aria-hidden="true"
      role="img"
      class={@class}
      viewBox="0 0 64 64"
      aria-hidden="true"
    >
      <path
        fill="#dde8e3"
        d="M2 31.4C2 40.2 5.7 53 17 53s15-12.8 15-21.6c0-27.2-30-27.2-30 0zm30 0C32 40.2 35.7 53 47 53s15-12.8 15-21.6c0-27.2-30-27.2-30 0"
      /><path
        fill="#fff"
        d="M2.8 32.1c0 7.6 2.4 19.3 12 19.3s12-11.8 12-19.3c-.1-26-24-26-24 0m30 0c0 7.6 2.4 19.3 12 19.3s12-11.8 12-19.3c-.1-26-24-26-24 0"
      /><path
        fill="#493b30"
        d="M2.8 32.2c0 6.2 4.4 11 9.7 11c5.4 0 9.7-4.8 9.7-11c0-15.2-19.4-15.2-19.4 0m30 0c0 6.2 4.4 11 9.7 11c5.4 0 9.7-4.8 9.7-11c0-15.2-19.4-15.2-19.4 0"
      />
    </svg>
    """
  end
end
