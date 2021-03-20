defmodule Bonfire.Web.LiveHandler do
  require Logger

  # start handler pattern matching

  alias Bonfire.Me.Web.LiveHandlers.{Profiles}
  alias Bonfire.Social.Web.LiveHandlers.{Flags, Boosts, Likes, Posts, Feeds, Follows}

  # TODO: put in config
  @like_events ["like"]
  @boost_events ["boost", "boost_undo"]
  @flag_events ["flag", "flag_undo"]
  @post_events ["post", "post_reply", "post_load_replies"]
  @post_infos [:thread_new_reply]
  @feed_events ["feed_load_more"]
  @feed_infos [:feed_new_activity]
  @follow_events ["follow", "unfollow"]
  @profile_events ["profile_save"]

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

  # uri
  defp do_handle_params(%{"feed" => params}, uri, socket), do: Feeds.handle_params(params, uri, socket)
  defp do_handle_event(event, attrs, socket) when event in @feed_events or binary_part(event, 0, 4) == "feed", do: Feeds.handle_event(event, attrs, socket)
  defp do_handle_info({info, data}, socket) when info in @feed_infos, do: Feeds.handle_info({info, data}, socket)

  # Follows
  defp do_handle_event(event, attrs, socket) when event in @follow_events or binary_part(event, 0, 6) == "follow", do: Follows.handle_event(event, attrs, socket)

  # Profiles
  defp do_handle_event(event, attrs, socket) when event in @profile_events or binary_part(event, 0, 7) == "profile", do: Profiles.handle_event(event, attrs, socket)

  # end of handler pattern matching
  defp do_handle_params(_, _, socket), do: {:noreply, socket}


  alias Bonfire.Common.Utils
  import Utils

  def handle_params(params, uri, socket) do
    undead(socket, fn ->
      # IO.inspect(params: params)
      do_handle_params(params, uri, socket)
    end)
  end

  def handle_event(event, attrs, socket) do
    undead(socket, fn ->
      do_handle_event(event, attrs, socket)
    end)
  end

  def handle_info(info, socket) do
    Logger.info("handle_info...")
    undead(socket, fn ->
      do_handle_info(info, socket)
    end)
  end

end
