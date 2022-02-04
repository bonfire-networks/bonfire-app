## About half of htis code is taken from hex, therefore this whole
## file is considered under the same license terms as hex.
defmodule Mix.Tasks.Bonfire.Account.New do
  use Mix.Task

  @shortdoc "Creates a new account in the database"

  @moduledoc """
  Creates an account in the database, automatically activated

  ## Usage

  ```
  mix bonfire.account.new [email@address]
  ```

  You will be prompted for a password and an email if it was not provided.
  """

  import Mix.Dep, only: [available?: 1, mix?: 1]
  alias Bonfire.Me.Fake

  @switches [include_children: :boolean, force: :boolean]

  @spec run(OptionParser.argv) :: :ok
  def run(args) do
    options = options(args, %{})
    Mix.Task.run("app.start")
    email = get("Enter an email address: ", :email, options, true)
    password = password("Enter a password:")
    IO.inspect(password: password)
    %{
      credential: %{password:      password},
      email:      %{email_address: email},
    }
    |> Fake.fake_account!()
  end

  defp options([], opts), do: opts
  defp options([email], opts), do: Map.put(opts, :email, email)
      
  defp get(prompt, key, opts, must?) do
    case opts[key] do
      nil ->
        case IO.gets(prompt) do
          :eof -> raise RuntimeError, message: "EOF"
          data when is_binary(data) -> get(prompt, key, Map.put(opts, key, data), must?)
          data when is_list(data)   -> get(prompt, key, Map.put(opts, key, to_string(data)), must?)
        end
      data ->
        data = String.trim(data)
        if data == "" do
          if must?, do: get(prompt, key, Map.delete(opts, key), must?), else: nil
        else
          data
        end
    end
  end

  # Extracted from hex via https://dev.to/tizpuppi/password-input-in-elixir-31oo
  defp password(prompt) do
    pid = spawn_link(fn -> loop(prompt) end)
    ref = make_ref()
    password(prompt, pid, ref)
  end
    
  defp password(prompt, pid, ref) do
    value = String.trim(IO.gets(prompt))
    if String.length(value) < 10 do
      IO.puts(:standard_error, "Password too short, must be at least 10 characters long")
      password(prompt, pid, ref)
    else
      send(pid, {:done, self(), ref})
      receive do
        {:done, ^pid, ^ref} -> value
      end
    end
  end

  defp loop(prompt) do
    receive do
      {:done, parent, ref} ->
        send(parent, {:done, self(), ref})
        IO.write(:standard_error, "\e[2K\r")
    after
      1 ->
        IO.write(:standard_error, "\e[2K\r#{prompt}")
        loop(prompt)
    end
  end

end
