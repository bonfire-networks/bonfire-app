use Mix.Config

config :bonfire_classify,
  templates_path: "lib"

config :bonfire_classify, Bonfire.Classify.Category,
  has_one: [actor:        {Bonfire.Data.ActivityPub.Actor,     foreign_key: :id}],
  has_one: [character:    {Bonfire.Data.Identity.Character,    foreign_key: :id}],
  has_one: [follow_count: {Bonfire.Data.Social.FollowCount,    foreign_key: :id}],
  has_one: [like_count:   {Bonfire.Data.Social.LikeCount,      foreign_key: :id}],
  has_one: [profile:      {Bonfire.Data.Social.Profile,        foreign_key: :id}]
