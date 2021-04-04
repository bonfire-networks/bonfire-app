import Config

config :bonfire, :hooks,
  %{
    {Bonfire.Social.Posts, :publish} => %{
      after: {IO, :inspect}
    }
  }
