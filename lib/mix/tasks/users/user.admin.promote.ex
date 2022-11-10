## About half of this code is taken from hex, therefore this whole
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

  alias Bonfire.Me.Users

  @spec run(OptionParser.argv()) :: :ok
  def run(args) do
    options = options(args, %{})
    Mix.Task.run("app.start")

    case Users.by_username!(options.username) do
      nil ->
        raise RuntimeError, message: "User not found"

      user ->
        Users.make_admin(user)
    end
  end

  defp options([username], opts), do: Map.put(opts, :username, username)
end
