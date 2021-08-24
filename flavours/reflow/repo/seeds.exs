import Bonfire.Me.Fake

System.put_env("SEARCH_INDEXING_DISABLED", "true")

_admin =
  %{
    preferred_username: System.get_env("SEEDS_USER", "root"),
    name: System.get_env("SEEDS_USER", "Seed User"),
    is_instance_admin: true
  }
  |> fake_user!(%{confirm_email: true})

# create some users
users = for _ <- 1..2, do: fake_user!()
random_user = fn -> Faker.Util.pick(users) end

# start some communities
#communities = for _ <- 1..2, do: fake_community!(random_user.())
#subcommunities = for _ <- 1..2, do: fake_community!(random_user.(), Faker.Util.pick(communities))
#maybe_random_community = fn -> maybe_one_of(communities ++ subcommunities) end

# create fake collections
#collections = for _ <- 1..4, do: fake_collection!(random_user.(), maybe_random_community.())
#subcollections = for _ <- 1..2, do: fake_collection!(random_user.(), Faker.Util.pick(collections))
#maybe_random_collection = fn -> maybe_one_of(collections ++ subcollections) end

# start fake threads
#for _ <- 1..3 do
#  user = random_user.()
#  thread = fake_thread!(user, maybe_random_community.())
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
#  thread = fake_thread!(user, maybe_random_collection.())
#  comment = fake_comment!(user, thread)
#end

# post some links/resources
#for _ <- 1..2, do: fake_resource!(random_user.(), maybe_random_community.())
#for _ <- 1..2, do: fake_resource!(random_user.(), maybe_random_collection.())

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

# conduct some fake economic activities
if(Bonfire.Common.Extend.extension_enabled?(ValueFlows.Simulate)) do
  for _ <- 1..2 do
    user = random_user.()
    action_id = ValueFlows.Simulate.action_id()

    # some lonesome intents and proposals
    _intent = ValueFlows.Simulate.fake_intent!(user, %{action_id: action_id})
    _proposal = ValueFlows.Simulate.fake_proposal!(user)
  end

  for _ <- 1..2 do
    user = random_user.()

    _process_spec = ValueFlows.Simulate.fake_process_specification!(user)
    res_spec = ValueFlows.Simulate.fake_resource_specification!(user)

    # some proposed intents
    action_id = ValueFlows.Simulate.action_id()
    intent = ValueFlows.Simulate.fake_intent!(user, %{resource_conforms_to: res_spec, action_id: action_id})
    proposal = ValueFlows.Simulate.fake_proposal!(user)
    ValueFlows.Simulate.fake_proposed_to!(random_user.(), proposal)
    ValueFlows.Simulate.fake_proposed_intent!(proposal, intent)

    # define some geolocations
    if(Bonfire.Common.Extend.extension_enabled?(Bonfire.Geolocate.Simulate)) do

      places = for _ <- 1..2, do: Bonfire.Geolocate.Simulate.fake_geolocation!(random_user.())
      random_place = fn -> Faker.Util.pick(places) end


      for _ <- 1..2 do
        # define some intents with geolocation
        _intent =
          ValueFlows.Simulate.fake_intent!(
            random_user.(),
            %{at_location: random_place.(), action_id: action_id}
          )

        # define some proposals with geolocation
        _proposal = ValueFlows.Simulate.fake_proposal!(user, %{eligible_location: random_place.()})

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

        resource_inventoried_as = ValueFlows.Simulate.fake_economic_resource!(user, %{current_location: random_place.()})
        to_resource_inventoried_as = ValueFlows.Simulate.fake_economic_resource!(random_user.(), %{current_location: random_place.()})

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

      for _ <- 1..2 do
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
        to_resource_inventoried_as = ValueFlows.Simulate.fake_economic_resource!(random_user.(), %{}, unit)

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
