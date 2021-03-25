defmodule Bonfire.Web.HomeLive do
  use Bonfire.Web, {:live_view, [layout: {Bonfire.Web.LayoutView, "without_sidebar.html"}]}
    alias Bonfire.Web.LivePlugs
    alias Bonfire.Me.Users
    def mount(params, session, socket) do
      LivePlugs.live_plug params, session, socket, [
        LivePlugs.LoadCurrentAccount,
        LivePlugs.LoadCurrentUser,
        LivePlugs.StaticChanged,
        LivePlugs.Csrf,
        &mounted/3,
      ]
    end

    defp mounted(params, session, socket) do
      feed_id = Bonfire.Social.Feeds.instance_feed_id()

      feed = Bonfire.Social.FeedActivities.feed(feed_id, e(socket.assigns, :current_user, nil))

      title = "Instance recent activities"
      {:ok, socket
      |> assign(
        page_title: "A Bonfire Instance",
        feed_title: title,
        feed_id: feed_id,
        feed: e(feed, :entries, []),
        page_info: e(feed, :metadata, [])
      )}
    end


    defdelegate handle_params(params, attrs, socket), to: Bonfire.Web.LiveHandler
    defdelegate handle_event(action, attrs, socket), to: Bonfire.Web.LiveHandler
    defdelegate handle_info(info, socket), to: Bonfire.Web.LiveHandler

  end
