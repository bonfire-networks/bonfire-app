defmodule VoxPublica.Fake do

  def email, do: Faker.Internet.email()
  # def location, do: Faker.Pokemon.location()
  def name, do: Faker.Person.name()
  def password, do: Faker.random_bytes(10)
  def summary, do: Faker.Pokemon.name()
  def username, do: Faker.Internet.user_name()

  def account(base \\ %{}) do
    base
    |> Map.put_new_lazy(:email, &email/0)
    |> Map.put_new_lazy(:password, &password/0)
  end

  def user(base \\ %{}) do
    base
    |> character()
    |> profile()
  end

  def character(base \\ %{}) do
    base
    |> Map.put_new_lazy(:username, &username/0)
  end

  def profile(base \\ %{}) do
    base
    |> Map.put_new_lazy(:name, &name/0)
    |> Map.put_new_lazy(:summary, &summary/0)
  end

end
