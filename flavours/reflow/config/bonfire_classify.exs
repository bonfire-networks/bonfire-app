import Config

config :bonfire_classify,
  templates_path: "lib"

config :bonfire_classify, Bonfire.Classify.Category,
  # for categories to be follow-able and federate activities
  has_one: [character:    {Bonfire.Data.Identity.Character,    references: :id, foreign_key: :id}],
  has_one: [actor:        {Bonfire.Data.ActivityPub.Actor,     references: :id, foreign_key: :id}],
  has_one: [follow_count: {Bonfire.Data.Social.FollowCount,    references: :id, foreign_key: :id}],
  # for likeability
  has_one: [like_count:   {Bonfire.Data.Social.LikeCount,      references: :id, foreign_key: :id}],
  # name/description
  has_one: [profile:      {Bonfire.Data.Social.Profile,        references: :id, foreign_key: :id}]
