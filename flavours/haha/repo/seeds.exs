# Script for populating the database. You can run it with `mix ecto.seeds`
#

import Bonfire.Me.Fake

System.put_env("INVITE_ONLY", "false")
System.put_env("SEARCH_INDEXING_DISABLED", "true")

%{
  preferred_username: System.get_env("SEEDS_USER", "root"),
  name: System.get_env("SEEDS_USER", "Seed User")
}
|> fake_user!(%{confirm_email: true})

# create some users
users = for _ <- 1..3, do: fake_user!()
random_user = fn -> Faker.Util.pick(users) end


# start fake threads
#for _ <- 1..3 do
#  user = random_user.()
#  thread = fake_thread!(user)
#  comment = fake_comment!(user, thread)
#  # reply to it
#  reply = fake_comment!(random_user.(), thread, %{in_reply_to_id: comment.id})
#  subreply = fake_comment!(random_user.(), thread, %{in_reply_to_id: reply.id})
#  subreply2 = fake_comment!(random_user.(), thread, %{in_reply_to_id: subreply.id})
#end
#
## more fake threads
#for _ <- 1..2 do
#  user = random_user.()
#  thread = fake_thread!(user)
#  comment = fake_comment!(user, thread)
#end


# define some tags/categories
if(Bonfire.Common.Extend.extension_enabled?(Bonfire.Classify.Simulate)) do
  for _ <- 1..2 do
    category = Bonfire.Classify.Simulate.fake_category!(random_user.())
    _subcategory = Bonfire.Classify.Simulate.fake_category!(random_user.(), category)
  end
end

# define some geolocations
if(Bonfire.Common.Extend.extension_enabled?(Bonfire.Geolocate.Simulate)) do
  for _ <- 1..2,
      do: Bonfire.Geolocate.Simulate.fake_geolocation!(random_user.())

  for _ <- 1..2,
      do: Bonfire.Geolocate.Simulate.fake_geolocation!(random_user.())
end

# define some units
if(Bonfire.Common.Extend.extension_enabled?(Bonfire.Quantify.Simulate)) do
  for _ <- 1..2 do
    _unit1 = Bonfire.Quantify.Simulate.fake_unit!(random_user.())
    _unit2 = Bonfire.Quantify.Simulate.fake_unit!(random_user.())
  end
end
