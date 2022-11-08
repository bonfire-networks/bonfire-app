defmodule Iconify.Fluent.MailEdit20Filled do
  use Phoenix.Component
  def render(assigns) do
    ~H"""
    <svg xmlns="http://www.w3.org/2000/svg" aria-hidden="true" role="img" class={@class} viewBox="0 0 20 20" aria-hidden="true"><path fill="currentColor" d="M18 6.374v2.76a2.87 2.87 0 0 0-2.898.707l-4.83 4.83a3.2 3.2 0 0 0-.798 1.33H4.5a2.5 2.5 0 0 1-2.5-2.5V6.374l7.747 4.558a.5.5 0 0 0 .507 0L18 6.374Zm-2.5-3.373a2.5 2.5 0 0 1 2.485 2.223L10 9.92L2.015 5.224A2.5 2.5 0 0 1 4.5 3h11Zm-4.52 12.376l4.83-4.83a1.87 1.87 0 1 1 2.644 2.646l-4.83 4.829a2.197 2.197 0 0 1-1.02.578l-1.498.374a.89.89 0 0 1-1.079-1.078l.375-1.498a2.18 2.18 0 0 1 .578-1.02Z"/></svg>
    """
  end
end
