defmodule VoxPublica.Web.IndexLive do
  use VoxPublica.Web, :live_view



  def mount(params, session, socket) do
    socket = init_assigns(params, session, socket)

    {:ok, socket
    |> assign(
      query: "",
      results: %{},
      selected_tab: "timeline",
      page_title: "My VoxPub"
    )}
  end

  def handle_params(%{"tab" => tab}, _url, socket) do
    {:noreply, assign(socket, selected_tab: tab)}
  end

  def handle_params(_, _url, socket) do
    {:noreply, assign(socket, selected_tab: "timeline")}
  end

  defp link_body(name, icon) do
    assigns = %{name: name, icon: icon}

    ~L"""
      <i class="<%= @icon %>"></i>
      <%= @name %>
    """
  end
end
