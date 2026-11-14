import Config

# The FEP-8a8e values split as Lauti splits its lists (and FEP-2fa1 its schemes): what kind of event it is (a `#Form`, Lauti's "categories") is a topic, in the chip bar; what it is about (a `#Topic`, Lauti's "topics") is a label, beside it. Flavours can move values between the two.
config :bonfire_gatherings, Bonfire.Gatherings.Events,  
  categories_nesting: %{
    "ARTS" => ["THEATRE", "COMEDY", "FILM_MEDIA",     "PHOTOGRAPHY", "CRAFTS", "MUSIC", "PERFORMING_VISUAL_ARTS"],
    "COMMUNITY" => ["MOVEMENTS_POLITICS", "DIY_MAKER_SPACES", "NETWORKING", "BOOK_CLUBS", "GAMES"],
    "CAUSES" => ["LGBTQ", "CLIMATE_ENVIRONMENT", "MEDITATION_WELLBEING", "SPIRITUALITY_RELIGION_BELIEFS"],
    "LEARNING" => ["LANGUAGE_CULTURE", "SCIENCE_TECH", "WORKSHOPS_SKILL_SHARING", "CREATIVE_JAM", "FAMILY_EDUCATION"],
    "OUTDOORS_ADVENTURE" => ["SPORTS"]
    # "FOOD_DRINK"
  },
  categories_as_labels: [
    "MEETING", 
    "FESTIVALS", 
    "INCLUSIVE_SPACES",
    "PETS",
    "BUSINESS",
    "PARTY", 
    "FASHION_BEAUTY",
    "AUTO_BOAT_AIR"
  ]
