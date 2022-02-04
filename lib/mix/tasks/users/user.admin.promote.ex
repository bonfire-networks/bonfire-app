## About half of htis code is taken from hex, therefore this whole
## file is considered under the same license terms as hex.
defmodule Mix.Tasks.Bonfire.User.Admin.Promote do
  use Mix.Task

  @shortdoc "Promotes a user to an administrator"

  @moduledoc """
  Creates an account in the database, automatically activated

  ## Usage

  ```
  mix bonfire.user.admin.promote username
  ```
  """

  import Mix.Dep, only: [available?: 1, mix?: 1]
  alias Bonfire.Me.Users

  @switches [include_children: :boolean, force: :boolean]

  @spec run(OptionParser.argv) :: :ok
  def run(args) do
    options = options(args, %{})
    Mix.Task.run("app.start")
    case Users.by_username!(options.username) do
      nil -> raise RuntimeError, message: "User not found"
      user ->
        {:ok, user} = Users.make_admin(user)
    end
  end

  defp options([username], opts), do: Map.put(opts, :username, username)

end
