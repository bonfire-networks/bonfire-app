defmodule Bonfire.ActivityPub.Adapter do
  @behaviour ActivityPub.Adapter

  alias ActivityPub.Actor
  alias Bonfire.Me.Identity.Users

  defp format_actor(user) do
    user = Bonfire.Repo.preload(user, [:actor])
    ap_base_path = Bonfire.Common.Config.get(:ap_base_path, "/pub")
    id = Bonfire.Web.Endpoint.url() <> ap_base_path <> "/actors/#{user.character.username}"

    data = %{
      "type" => "Person",
      "id" => id,
      "inbox" => "#{id}/inbox",
      "outbox" => "#{id}/outbox",
      "followers" => "#{id}/followers",
      "following" => "#{id}/following",
      "preferredUsername" => user.character.username,
      "name" => user.profile.name,
      "summary" => Map.get(user.profile, :summary)
    }

    %Actor{
      id: user.id,
      data: data,
      keys: Bonfire.Common.Utils.maybe_get(user.actor, :signing_key),
      local: true,
      ap_id: id,
      pointer_id: user.id,
      username: user.character.username,
      deactivated: false
    }
  end

  def get_actor_by_username(username) do
    with {:ok, user} <- Users.ActivityPub.by_username(username),
         actor <- format_actor(user) do
      {:ok, actor}
    else
      _ ->
        {:error, :not_found}
    end
  end

  def update_local_actor(actor, params) do
    with {:ok, user} <- Users.ActivityPub.by_username(actor.username),
         {:ok, user} <-
           Users.ActivityPub.update(user, Map.put(params, :actor, %{signing_key: params.keys})),
         actor <- format_actor(user) do
      {:ok, actor}
    end
  end
end
