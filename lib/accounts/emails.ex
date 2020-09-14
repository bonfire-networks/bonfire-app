defmodule VoxPublica.Accounts.Emails do

  import Bamboo.Email
  import Bamboo.Phoenix
  alias CommonsPub.Accounts.Account
  alias Pointers.Changesets
  alias VoxPublica.Web.EmailView

  def confirm_email(%Account{email: %{email: email}}=account) when is_binary(email) do
    conf =
      Application.get_env(:vox_publica, __MODULE__, [])
      |> Keyword.get(:confirm_email, [])
    new_email()
    |> subject(Keyword.get(conf, :subject, "Confirm your email - VoxPublica"))
    |> put_html_layout({EmailView, "confirm_email.html"})
    |> put_text_layout({EmailView, "confirm_email.text"})
  end

  def reset_password(%Account{email: %{email: email}}=account) when is_binary(email) do
    conf =
      Application.get_env(:vox_publica, __MODULE__, [])
      |> Keyword.get(:reset_password_email, [])
    new_email()
    |> subject(Keyword.get(conf, :subject, "Reset your password - VoxPublica"))
    |> put_html_layout({EmailView, "reset_password.html"})
    |> put_text_layout({EmailView, "reset_password.text"})
  end

end
