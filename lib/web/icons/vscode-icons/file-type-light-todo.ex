defmodule Iconify.VscodeIcons.FileTypeLightTodo do
  use Phoenix.Component
  def render(assigns) do
    ~H"""
    <svg xmlns="http://www.w3.org/2000/svg" aria-hidden="true" role="img" class={@class} viewBox="0 0 32 32" aria-hidden="true"><path fill="green" d="m17.866 15.509l-.98.98l-.98-.978l-1.957-1.957l.977-.977l1.957 1.957l4.891-4.894l.98.977l-4.888 4.892z"/><path fill="#c00000" d="M14.454 21.443h8.303v1.383h-8.303z"/><path d="M2 5.74v23.709h24.909V5.74Zm23.477 22.449l-22.083-.058l.023-20.974h22.077ZM6.151 10.951v5.534h5.534v-5.534ZM10.3 15.1H7.534v-2.766H10.3Zm-4.151 4.22v5.534h5.534v-5.531Zm4.151 4.154H7.534v-2.765H10.3ZM30 2.551V26.24h-1.431L28.549 4l-22.4-.029v-1.42H30Z"/></svg>
    """
  end
end
