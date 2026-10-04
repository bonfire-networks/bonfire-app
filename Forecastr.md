# Forecastr ![Build Status](https://secure.travis-ci.org/kpanic/forecastr.png?branch=master "Build Status") ![Package Version](https://img.shields.io/hexpm/v/forecastr.svg "Package Version") ![License](https://img.shields.io/hexpm/l/forecastr.svg "License")


Forecastr is an open source Weather API wrapper for OpenWeatherMap and PirateWeather API.

Forecastr is an Elixir flavour of http://wttr.in that talks directly to one of
the aforementioned weather services.

Aim of the project is to provide a website similar to wttr.in written entirely in elixir

**Project status: beta**

## Installation

The package can be installed by adding `forecastr` to your list of dependencies
in `mix.exs`:

```elixir
def deps do
  [
    {:forecastr, "~> 0.3"}
  ]
end
```

The documentation can be found at
[https://hexdocs.pm/forecastr](https://hexdocs.pm/forecastr).


**NOTE**
If you want to play with this project you have to obtain an api key from
http://openweathermap.org/ or https://darksky.net/ and:

```bash
export FORECASTR_API_KEY=YOUR_API_KEY
```

Also put in your `config/config.exs`

```elixir
config :forecastr,
  appid: System.get_env("FORECASTR_API_KEY"),
  backend: Forecastr.OWM,
  # 10 minutes by default
  ttl: 10 * 60_000
```

If you want to use the DarkSky API put `backend: Forecastr.Darksky`

Samples of output for today's forecast:

```elixir
Forecastr.forecast(:today, "lima")
```

![today](today.png)
![berlin](berlin.png)

Sample output with the OWM backend (the number of days is different depending on the backend used):

```elixir
Forecastr.forecast(:next_days, "lima")
```

![in 5 days](in_five_days.png)

> "*All the ducks are swimming in the water
> Fal de ral de ral do*" (Lemon Jelly cit.)

![duck with sunglasses](duck_with_sunglasses.jpg)

If you want *gifs* back with your weather forecast from **Giphy** call the giphy
renderer:

```elixir
iex> Forecastr.forecast(:today, "berlin", units: :metric, renderer: Forecastr.Renderer.Giphy)
{:ok,
 %{
   "coordinates" => %{"lat" => 52.5170365, "lon" => 13.3888599},
   "country" => "Deutschland",
   "description" => "Mostly Cloudy",
   "giphy_pic" => "https://i.giphy.com/media/XqL0uC2RUx9Hq/200.gif",
   "id" => "partly-cloudy-day",
   "name" => "Berlin",
   "temp" => 9.77,
   "temp_max" => 9.77,
   "temp_min" => 9.77
 }}
```

This works also by calling `Forecastr.forecast` with the `:next_days` atom to
get the weather forecast for the next days.

# TODO
- [X] Travis
- [X] JSON renderer
- [X] PNG Renderer with transparency (it's there but needs some love)
- [X] Integrate https://forecast.io (now DarkSky) as a backend.
- [X] Giphy renderer
- [ ] Tests! (some coverage, good enough for now ™, however if someone feels like to add more.. ;))
- [ ] Correct ASCII Art for the renderers that supports that (In progress)

# Thank yous

* The https://wttr.in project for inspiration
* ![wego](https://github.com/schachmat/wego) for the amazing ASCII art
