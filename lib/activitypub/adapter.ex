defmodule VoxPublica.ActivityPub.Adapter do
  @behaviour ActivityPub.Adapter

  alias ActivityPub.Actor
  alias VoxPublica.Users

  defp format_actor(user) do
    ap_base_path = System.get_env("AP_BASE_PATH", "/pub")
    id = VoxPublica.Web.Endpoint.url() <> ap_base_path <> "/actors/#{user.character.username}"

    data = %{
      "type" => "Person",
      "id" => id,
      "inbox" => "#{id}/inbox",
      "outbox" => "#{id}/outbox",
      "followers" => "#{id}/followers",
      "following" => "#{id}/following",
      "preferredUsername" => user.character.username,
      "name" => user.profile.name,
      "summary" => Map.get(user.profile, :summary),
    }

    %Actor{
      id: user.id,
      data: data,
      keys: nil, # TODO
      local: true,
      ap_id: id,
      pointer_id: user.id,
      username: user.character.username,
      deactivated: false
    }
  end

  def get_actor_by_username(username) do
    with {:ok, user} <- Users.by_username(username),
         actor <- format_actor(user) do
      {:ok, actor}
    else
      _ -> {:error, "not found"}
    end
  end

  # FIXME: make this actually do the update
  def update_local_actor(actor, params) do
    actor = Map.put(actor, :keys, params.keys)
    {:ok, actor}
  end
end
