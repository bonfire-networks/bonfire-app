defmodule VoxPublica.Fake do

  def email, do: Faker.Internet.email()
  def confirm_token, do: Base.encode32(Faker.random_bytes(10), pad: false)
  # def location, do: Faker.Pokemon.location()
  def name, do: Faker.Person.name()
  def password, do: Base.encode32(Faker.random_bytes(10), pad: false)
  def summary, do: Faker.Lorem.sentence(6..15)
  def username, do: String.replace(Faker.Internet.user_name(), ~r/\./, "_")
  def website, do: Faker.Internet.domain_name()
  def location, do: Faker.Pokemon.location()
  def icon_url, do: Faker.Avatar.image_url(140,140)
  def image_url, do: Faker.Avatar.image_url()

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

  def user_live(base \\ %{}) do
    base
    |> user()
    |> Map.put_new_lazy(:location, &location/0)
    |> Map.put_new_lazy(:id, &username/0)
    |> Map.put_new_lazy(:website, &website/0)
    |> Map.put_new_lazy(:icon_url, &icon_url/0)
    |> Map.put_new_lazy(:image_url, &image_url/0)
    |> Map.put_new(:is_followed, false)
    |> Map.put_new(:is_instance_admin, true)
  end
end
