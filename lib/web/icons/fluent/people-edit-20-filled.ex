defmodule Iconify.Fluent.PeopleEdit20Filled do
  use Phoenix.Component
  def render(assigns) do
    ~H"""
    <svg xmlns="http://www.w3.org/2000/svg" aria-hidden="true" role="img" class={@class} viewBox="0 0 20 20" aria-hidden="true"><path fill="currentColor" d="M6.75 9a3.25 3.25 0 1 0 0-6.5a3.25 3.25 0 0 0 0 6.5ZM10 10a2 2 0 0 1 2 1.944l-1.726 1.726a3.2 3.2 0 0 0-.841 1.485l-.106.423c-.675.26-1.52.422-2.577.422c-5.25 0-5.25-4-5.25-4a2 2 0 0 1 2-2H10Zm7-3.5a2.499 2.499 0 1 1-5 0a2.5 2.5 0 0 1 5 0Zm-1.19 3.048l-4.83 4.83a2.197 2.197 0 0 0-.578 1.02l-.375 1.498a.89.89 0 0 0 1.079 1.078l1.498-.374a2.194 2.194 0 0 0 1.02-.578l4.83-4.83a1.87 1.87 0 0 0-2.645-2.644Z"/></svg>
    """
  end
end
