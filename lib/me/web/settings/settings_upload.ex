defmodule CommonsPub.Me.Web.My.SettingsUpload do
  use CommonsPub.Me.UseModule, [:web_module, :controller]

  # params we receive:
  # %{
  #   "_csrf_token" => "yHxqH5EG6NtAe0B433A3njID",
  #   "profile" => %{
  #     "email" => "test@jfdgkjdf.space",
  #     "icon" => %Plug.Upload{
  #       content_type: "image/png",
  #       filename: "fist.png",
  #       path: "/tmp/plug-1595/multipart-1595441441-553343146418336-1"
  #     },
  #     "location" => "",
  #     "name" => "namie",
  #     "summary" => "yay"
  #   },
  # }

  def upload(%{assigns: %{current_user: current_user}} = conn, params) do
    attrs = input_to_atoms(params)

    # maybe_upload(params["profile"]["icon"], "icon")
    # maybe_upload(params["profile"]["image"], "image")

    # TODO
    # {:ok, _edit_profile} =
    #   CommonsPub.Web.GraphQL.UsersResolver.update_profile(attrs, %{
    #     context: %{current_user: current_user}
    #   })

    conn
    |> redirect(external: "/profile")
  end
end
