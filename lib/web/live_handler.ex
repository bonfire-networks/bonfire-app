defmodule Bonfire.Web.LiveHandler do
  use Bonfire.Web, :live_handler
  require Logger

  # start handler pattern matching

  alias Bonfire.Me.Web.LiveHandlers.{Profiles, Circles}
  alias Bonfire.Social.Web.LiveHandlers.{Flags, Boosts, Likes, Posts, Feeds, Follows}

  # TODO: make this whole thing config-driven
  @profile_events ["profile_save"]

  @circle_events ["circle_save"]

  @boundary_events ["boundary_select"]

  @like_events ["like"]

  @boost_events ["boost", "boost_undo"]

  @flag_events ["flag", "flag_undo"]

  @post_events ["post", "post_reply", "post_load_replies"]
  @post_infos [:post_new_reply]

  @feed_events ["feed_load_more"]
  @feed_infos [:feed_new_activity]

  @follow_events ["follow", "unfollow"]


  # Profiles
  defp do_handle_event(event, attrs, socket) when event in @profile_events or binary_part(event, 0, 7) == "profile", do: Profiles.handle_event(event, attrs, socket)

  # Circles
  defp do_handle_event(event, attrs, socket) when event in @circle_events or binary_part(event, 0, 6) == "circle", do: Circles.handle_event(event, attrs, socket)

  # Boundaries
  defp do_handle_event(event, attrs, socket) when event in @boundary_events or binary_part(event, 0, 8) == "boundary", do: Bonfire.Me.Web.LiveHandlers.Boundaries.handle_event(event, attrs, socket)

  # Likes
  defp do_handle_event(event, attrs, socket) when event in @like_events or binary_part(event, 0, 4) == "like", do: Likes.handle_event(event, attrs, socket)

  # Boosts
  defp do_handle_event(event, attrs, socket) when event in @boost_events or binary_part(event, 0, 5) == "boost", do: Boosts.handle_event(event, attrs, socket)

  # Flags
  defp do_handle_event(event, attrs, socket) when event in @flag_events or binary_part(event, 0, 4) == "flag", do: Flags.handle_event(event, attrs, socket)

  # Posts
  defp do_handle_params(%{"post" => params}, uri, socket), do: Posts.handle_params(params, uri, socket)
  defp do_handle_event(event, attrs, socket) when event in @post_events or binary_part(event, 0, 4) == "post", do: Posts.handle_event(event, attrs, socket)
  defp do_handle_info({info, data}, socket) when info in @post_infos, do: Posts.handle_info({info, data}, socket)
  defp do_handle_info({info, id, data}, socket) when info in @post_infos, do: Posts.handle_info({info, id, data}, socket)

  # Feeds
  defp do_handle_params(%{"feed" => params}, uri, socket), do: Feeds.handle_params(params, uri, socket)
  defp do_handle_event(event, attrs, socket) when event in @feed_events or binary_part(event, 0, 4) == "feed", do: Feeds.handle_event(event, attrs, socket)
  defp do_handle_info({info, data}, socket) when info in @feed_infos, do: Feeds.handle_info({info, data}, socket)

  # Follows
  defp do_handle_event(event, attrs, socket) when event in @follow_events or binary_part(event, 0, 6) == "follow", do: Follows.handle_event(event, attrs, socket)

  # Search
  # defp do_handle_event(event, attrs, socket) when binary_part(event, 0, 6) == "search", do: Bonfire.Search.LiveHandler.handle_event(event, attrs, socket)

  # ValueFlows
  # defp do_handle_event(event, attrs, socket) when binary_part(event, 0, 10) == "valueflows", do: ValueFlows.Web.LiveHandler.handle_event(event, attrs, socket)

  defp do_handle_event(event, attrs, socket) do
    # IO.inspect(handle_event: event)
    [mod, action] = String.split(event, ":", parts: 2)
    # IO.inspect(mod)
    # IO.inspect(action)
    case Utils.maybe_str_to_module(mod<>".LiveHandler") || Utils.maybe_str_to_module(mod) do
      module when is_atom(module) ->
        # IO.inspect(module)
        if Utils.module_enabled?(module), do: apply(module, :handle_event, [action, attrs, socket]),
        else: empty(socket)
      _ -> empty(socket)
    end
  end

  # end of handler pattern matching - fallback with empty replies
  defp do_handle_params(_, _, socket), do: empty(socket)
  defp do_handle_event(_, _, socket), do: empty(socket)
  defp do_handle_info(_, socket), do: empty(socket)

  defp empty(socket), do: {:noreply, socket}

  def handle_params(params, uri, socket, _source_module \\ nil) do
    undead(socket, fn ->
      ## IO.inspect(params: params)
      do_handle_params(params, uri, socket |> assign(current_url: URI.parse(uri).path))
    end)
  end

  def handle_event(action, attrs, socket, source_module \\ nil) do
    undead(socket, fn ->
      Logger.info("handle_event in #{inspect source_module}: #{action}...")
      do_handle_event(action, attrs, socket)
    end)
  end

  def handle_info(blob, socket, source_module \\ nil)

  # global handler to set a view's assigns from a component
  def handle_info({:assign, {assign, value}}, socket, _) do
    undead(socket, fn ->
      IO.inspect(assigns_to_set: assign)
      {:noreply,
        socket
        |> Utils.assign_global(assign, value)
        # |> Phoenix.LiveView.assign(:global_assigns, [assign] ++ Map.get(socket.assigns, :global_assigns, []))
        # |> IO.inspect(limit: :infinity)
      }
  end)
  end

  def handle_info({info, _data} = blob, socket, source_module) when is_atom(source_module) do
    # IO.inspect(socket)
    Logger.info("handle_info in #{source_module}: #{info}...")
    undead(socket, fn ->
      do_handle_info(blob, socket)
    end)
  end
  def handle_info(info, socket, _) do
    Logger.info("handle_info...")
    undead(socket, fn ->
      do_handle_info(info, socket)
    end)
  end
end
