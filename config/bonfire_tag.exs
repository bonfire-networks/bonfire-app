import Config

config :bonfire_tag,
  templates_path: "lib"

# optional mixin relations for tags that are characters (eg Category) or any other type of objects
# config :bonfire_tag, Bonfire.Tag,
#   # for objects that are follow-able and can federate activities
#   has_one: [character:    {Bonfire.Data.Identity.Character,    references: :id, foreign_key: :id}],
#   has_one: [actor:        {Bonfire.Data.ActivityPub.Actor,     references: :id, foreign_key: :id}],
#   has_one: [follow_count: {Bonfire.Data.Social.FollowCount,    references: :id, foreign_key: :id}],
#   # for likeable objects
#   has_one: [like_count:   {Bonfire.Data.Social.LikeCount,      references: :id, foreign_key: :id}],
#   # name/description
#   has_one: [profile:      {Bonfire.Data.Social.Profile,        references: :id, foreign_key: :id}],
#   # for taxonomy categories/topics
#   has_one: [category:     {Bonfire.Classify.Category,          references: :id, foreign_key: :id}],
#   # for locations
#   has_one: [geolocation:  {Bonfire.Geolocate.Geolocation,      references: :id, foreign_key: :id}]

# add references of tags to any tagged Pointer
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

# add references of tagged objects to any Category
config :bonfire_classify, Bonfire.Classify.Category,
  many_to_many: [
    tags: {
      Bonfire.Tag,
      join_through: "bonfire_tagged",
      unique: true,
      join_keys: [tag_id: :id, pointer_id: :id],
      on_replace: :delete
    }
  ]

# add references of tagged objects to any Geolocation
config :bonfire_geolocate, Bonfire.Geolocate.Geolocation,
  many_to_many: [
    tags: {
      Bonfire.Tag,
      join_through: "bonfire_tagged",
      unique: true,
      join_keys: [tag_id: :id, pointer_id: :id],
      on_replace: :delete
    }
  ]
