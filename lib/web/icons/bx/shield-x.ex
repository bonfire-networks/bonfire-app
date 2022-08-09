defmodule Iconify.Bx.ShieldX do
  use Phoenix.Component
  def render(assigns) do
    ~H"""
    <svg xmlns="http://www.w3.org/2000/svg" aria-hidden="true" role="img" class={@class} viewBox="0 0 24 24" aria-hidden="true"><path fill="currentColor" d="m20.48 6.105l-8-4a1 1 0 0 0-.895 0l-8 4a1.002 1.002 0 0 0-.547.795c-.011.107-.961 10.767 8.589 15.014a.99.99 0 0 0 .812 0c9.55-4.247 8.6-14.906 8.589-15.014a1.001 1.001 0 0 0-.548-.795zm-8.447 13.792C5.265 16.625 4.944 9.642 4.999 7.635l7.034-3.517l7.029 3.515c.038 1.989-.328 9.018-7.029 12.264z"/><path fill="currentColor" d="M14.293 8.293L12 10.586L9.707 8.293L8.293 9.707L10.586 12l-2.293 2.293l1.414 1.414L12 13.414l2.293 2.293l1.414-1.414L13.414 12l2.293-2.293z"/></svg>
    """
  end
end
