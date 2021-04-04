import Config

config :bonfire, :hooks,
  %{
    {Bonfire.Social.Posts, :publish, 2} => {IO, :inspect}
  }
