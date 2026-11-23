import Config

config :bonfire_geolocate,
  templates_path: "lib"

# the feed filters this extension owns: things whose place is within a radius of a point (`nearby: %{lat, long, km, include_no_place}`), or inside a box (`within_bounds: %{south, west, north, east}`, or `%{has_place: true}`). Declared here as fields on another extension's struct because `Exto` reads this at compile time and a struct's fields have to exist when it compiles; `Bonfire.Geolocate.FeedFilters` is what applies them
config :bonfire_social, Bonfire.Social.FeedFilters, field: [nearby: :map, within_bounds: :map]

# the map styles (of the styles' server set by `MAP_STYLES_URL`, OpenFreeMap's by default), which instances and users pick from, and the default one; a style can also be a full URL (eg. of a self-hosted Protomaps style)
config :bonfire_geolocate, Bonfire.Geolocate,
  # names an incoming Place may have that are not somewhere to put on a map (matched whole, any case), so they are not sent to the geocoder
  non_place_names: ["online", "internet", "virtual", "tba", "tbd", "zoom", "web", "webinar"],
  # a name of up to this many words, with no comma, that has one of those words in it (eg. "Online event", "Zoom call") is not geocoded either
  non_place_name_max_words: 3,
  map_style: "liberty",
  map_styles: [
    liberty: "Liberty",
    bright: "Bright",
    positron: "Positron",
    dark: "Dark",
    fiord: "Fiord"
  ]
