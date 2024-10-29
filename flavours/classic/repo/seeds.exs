# Script for populating the database. You can run it with `mix ecto.seeds`
#

use Bonfire.Common.E
import Bonfire.Me.Fake
import Bonfire.Social.Fake
import Bonfire.Posts.Fake

# num_users = 100
# num_objects = 100000
# num_sub_objects = 50
num_users = 3
num_objects = 10
num_sub_objects = 10

System.put_env("INVITE_ONLY", "false")
System.put_env("SEARCH_INDEXING_DISABLED", "true")

Application.put_env(:bonfire_common, Bonfire.Common.AntiSpam,
  service: Bonfire.Common.AntiSpam.Mock
)

# if the user has configured an admin user for the seeds, insert it.
case {System.get_env("ADMIN_USER", "root"), System.get_env("ADMIN_PASSWORD", "")} do
  {u, p} when p != "" ->
    fake_account!(%{credential: %{password: p}})
    |> fake_user!(%{username: u, name: u})
    |> Bonfire.Me.Users.make_admin()

  _ ->
    nil
end

# create some users
users = for _ <- 1..num_users, do: fake_user!()
random_user = fn -> Faker.Util.pick(users) end

# start fake threads
threads =
  for i <- 1..num_objects do
    thread =
      case Faker.Util.pick(1..3) do
        1 ->
          fake_post!(random_user.())

        2 ->
          fake_post!(random_user.(), "public", %{
            post_content: %{
              summary: "test #{i} with #hashtag"
            }
          })

        3 ->
          fake_post!(random_user.(), "public", %{
            post_content: %{
              summary: "@#{e(random_user.(), :character, :username, nil)} test mention #{i}"
            }
          })
      end

    comments = for i <- 1..num_sub_objects, do: fake_comment!(random_user.(), thread)

    _sub_comment =
      for i <- 1..num_sub_objects, do: fake_comment!(random_user.(), Faker.Util.pick(comments))

    thread
  end

# random_thread = fn -> Faker.Util.pick(threads) end

# define some tags/categories
if(
  Bonfire.Common.Extend.extension_enabled?(Bonfire.UI.Groups) or
    Bonfire.Common.Extend.extension_enabled?(Bonfire.UI.Topics)
) do
  for _ <- 1..num_objects do
    category = Bonfire.Classify.Simulate.fake_category!(random_user.())

    for i <- 1..num_sub_objects do
      subcategory = Bonfire.Classify.Simulate.fake_category!(random_user.(), category)

      for i <- 1..num_sub_objects do
        _subsubcategory = Bonfire.Classify.Simulate.fake_category!(random_user.(), subcategory)
      end
    end
  end
end

# define some geolocations
if(Bonfire.Common.Extend.extension_enabled?(Bonfire.Geolocate.Simulate)) do
  for _ <- 1..num_objects,
      do: Bonfire.Geolocate.Simulate.fake_geolocation!(random_user.())
end

# define some units
if(Bonfire.Common.Extend.extension_enabled?(Bonfire.Quantify.Simulate)) do
  for _ <- 1..num_objects do
    Bonfire.Quantify.Simulate.fake_unit!(random_user.())
  end
end

# conduct some fake economic activities
if(Bonfire.Common.Extend.extension_enabled?(ValueFlows.Simulate)) do
  for _ <- 1..num_objects do
    user = random_user.()
    action_id = ValueFlows.Simulate.action_id()

    # some lonesome intents and proposals
    _intent = ValueFlows.Simulate.fake_intent!(user, %{action_id: action_id})
    _proposal = ValueFlows.Simulate.fake_proposal!(user)
  end

  for _ <- 1..num_objects do
    user = random_user.()

    _process_spec = ValueFlows.Simulate.fake_process_specification!(user)
    res_spec = ValueFlows.Simulate.fake_resource_specification!(user)

    # some proposed intents
    action_id = ValueFlows.Simulate.action_id()

    intent =
      ValueFlows.Simulate.fake_intent!(user, %{
        resource_conforms_to: res_spec,
        action_id: action_id
      })

    proposal = ValueFlows.Simulate.fake_proposal!(user)
    ValueFlows.Simulate.fake_proposed_to!(random_user.(), proposal)
    ValueFlows.Simulate.fake_proposed_intent!(proposal, intent)

    # define some geolocations
    if(Bonfire.Common.Extend.extension_enabled?(Bonfire.Geolocate.Simulate)) do
      places =
        for _ <- 1..num_objects, do: Bonfire.Geolocate.Simulate.fake_geolocation!(random_user.())

      random_place = fn -> Faker.Util.pick(places) end

      for _ <- 1..num_objects do
        # define some intents with geolocation
        _intent =
          ValueFlows.Simulate.fake_intent!(
            random_user.(),
            %{at_location: random_place.(), action_id: action_id}
          )

        # define some proposals with geolocation
        _proposal =
          ValueFlows.Simulate.fake_proposal!(user, %{eligible_location: random_place.()})

        # both with geo
        intent =
          ValueFlows.Simulate.fake_intent!(
            random_user.(),
            %{at_location: random_place.(), action_id: action_id}
          )

        proposal = ValueFlows.Simulate.fake_proposal!(user, %{eligible_location: random_place.()})
        ValueFlows.Simulate.fake_proposed_intent!(proposal, intent)

        # some economic events
        user = random_user.()

        resource_inventoried_as =
          ValueFlows.Simulate.fake_economic_resource!(user, %{current_location: random_place.()})

        to_resource_inventoried_as =
          ValueFlows.Simulate.fake_economic_resource!(random_user.(), %{
            current_location: random_place.()
          })

        ValueFlows.Simulate.fake_economic_event!(
          user,
          %{
            to_resource_inventoried_as: to_resource_inventoried_as.id,
            resource_inventoried_as: resource_inventoried_as.id,
            action: Faker.Util.pick(["transfer", "move"]),
            at_location: random_place.()
          }
        )
      end
    end

    if(Bonfire.Common.Extend.extension_enabled?(Bonfire.Quantify.Simulate)) do
      unit1 = Bonfire.Quantify.Simulate.fake_unit!(random_user.())
      unit2 = Bonfire.Quantify.Simulate.fake_unit!(random_user.())

      for _ <- 1..num_objects do
        action_id = ValueFlows.Simulate.action_id()
        # define some intents with measurements
        intent =
          ValueFlows.Simulate.fake_intent!(
            random_user.(),
            %{action_id: action_id},
            Faker.Util.pick([unit1, unit2])
          )

        proposal = ValueFlows.Simulate.fake_proposal!(user)
        ValueFlows.Simulate.fake_proposed_intent!(proposal, intent)

        # some economic events
        user = random_user.()
        unit = Faker.Util.pick([unit1, unit2])

        resource_inventoried_as = ValueFlows.Simulate.fake_economic_resource!(user, %{}, unit)

        to_resource_inventoried_as =
          ValueFlows.Simulate.fake_economic_resource!(random_user.(), %{}, unit)

        ValueFlows.Simulate.fake_economic_event!(
          user,
          %{
            to_resource_inventoried_as: to_resource_inventoried_as.id,
            resource_inventoried_as: resource_inventoried_as.id,
            action: Faker.Util.pick(["transfer", "move"])
          },
          unit
        )
      end
    end
  end
end
