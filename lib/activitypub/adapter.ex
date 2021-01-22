defmodule Bonfire.ActivityPub.Adapter do
  @behaviour ActivityPub.Adapter

  def get_actor_by_username(username) do
    module = Application.get_env(:bonfire, Bonfire.ActivityPub.Adapter)[:users_module]
    apply(module, :get_actor_by_username, [username])
  end

  def update_local_actor(actor, params) do
    module = Application.get_env(:bonfire, Bonfire.ActivityPub.Adapter)[:users_module]
    apply(module, :update_local_actor, [actor, params])
  end

  def maybe_create_remote_actor(actor) do
    module = Application.get_env(:bonfire, Bonfire.ActivityPub.Adapter)[:users_module]
    apply(module, :maybe_create_remote_actor, [actor])
  end

  def base_url() do
    module = Application.get_env(:bonfire, Bonfire.ActivityPub.Adapter)[:endpoint_module]
    apply(module, :url, [])
  end
end
