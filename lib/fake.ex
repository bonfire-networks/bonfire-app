defmodule VoxPublica.Fake do

  def email, do: Faker.Internet.email()
  # def location, do: Faker.Pokemon.location()
  def name, do: Faker.Person.name()
  def password, do: Base.encode64(Faker.random_bytes(10), pad: false)
  def summary, do: Faker.Lorem.sentence(6..15)
  def username, do: String.replace(Faker.Internet.user_name(), ~r/\./, "_")

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
