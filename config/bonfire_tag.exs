use Mix.Config

config :bonfire_tag,
  templates_path: "lib"

# optional mixin relations for tags that are characters (eg Category)
# config :bonfire_tag, Bonfire.Tag,
#   has_one: [actor:        {Bonfire.Data.ActivityPub.Actor,     references: :id, foreign_key: :id}],
#   has_one: [character:    {Bonfire.Data.Identity.Character,    references: :id, foreign_key: :id}],
#   has_one: [follow_count: {Bonfire.Data.Social.FollowCount,    references: :id, foreign_key: :id}],
#   has_one: [like_count:   {Bonfire.Data.Social.LikeCount,      references: :id, foreign_key: :id}],
#   has_one: [profile:      {Bonfire.Data.Social.Profile,        references: :id, foreign_key: :id}],
#   has_one: [category:     {Bonfire.Classify.Category,          references: :id, foreign_key: :id}]

# add tags reference to Pointer
config :pointers, Pointers.Pointer,
  many_to_many: [
    tags: {
      Bonfire.Tag,
      join_through: "bonfire_tagged",
      unique: true,
      join_keys: [pointer_id: :id, tag_id: :id],
      on_replace: :delete
    }
  ]
