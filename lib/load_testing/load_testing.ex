defmodule Mix.Tasks.Bonfire.LoadTesting do
  use Mix.Task

  def run(_) do
    # This will start our application
    Mix.Task.run("app.start")

    Bonfire.Federate.ActivityPub.LoadTesting.run_bench()
  end
end

defmodule Bonfire.Federate.ActivityPub.LoadTesting do
  # @endpoint Bonfire.Web.Endpoint
  import Bonfire.UI.Common.Testing.Helpers
  # import Phoenix.ConnTest
  alias Bonfire.Posts.Fake
  alias Bonfire.Common.Config
  alias Bonfire.Common.TestInstanceRepo
  # import Untangle

  def run_bench() do
    Logger.configure(level: :warning)

    Benchee.run(
      cases(),
      # other_cases(),
      parallel: 2,
      warmup: 2,
      time: 5,
      memory_time: 2,
      reduction_time: 2,
      profile_after: true,
      formatters: formatters("benchmarks/output/load_testing.html")
      # inputs: ""=>nil
    )

    Logger.configure(level: :info)
  end

  def cases do
    # conn = build_conn()
    local_me = fancy_fake_user!("local tester")
    # local_post = Fake.fake_post!(local_me[:user], "public") 
    # local_post_url = Bonfire.Common.URIs.canonical_url(local_post)

    %{
      # "fetch local outbox" => fn -> get(conn, "/pub/shared_outbox") end,

      "fetch user remotely by URL" => fn ->
        local_user = fake_user!()

        TestInstanceRepo.apply(fn ->
          Bonfire.Common.URIs.canonical_url(local_user)
          |> Bonfire.Federate.ActivityPub.AdapterUtils.get_by_url_ap_id_or_username()
        end)
      end,
      "fetch user remotely by username" => fn ->
        local_user = fake_user!()

        TestInstanceRepo.apply(fn ->
          Bonfire.Common.URIs.canonical_url(local_user)
          |> Bonfire.Federate.ActivityPub.AdapterUtils.get_by_url_ap_id_or_username()
        end)
      end,
      "just create local-only post" => fn ->
        post = Fake.fake_post!(local_me[:user], "local")
      end,
      "just create public post" => fn ->
        post = Fake.fake_post!(local_me[:user], "public")
      end
      # "fetch post remotely by URL" => fn ->
      #     local_post = Fake.fake_post!(local_me[:user], "public") 
      #     local_post_url = Bonfire.Common.URIs.canonical_url(local_post)
      # FIXME
      #     TestInstanceRepo.apply(fn -> 
      #     Bonfire.Federate.ActivityPub.AdapterUtils.get_by_url_ap_id_or_username(local_post_url)
      #     end)
      # end
    }
  end

  if Config.get(:env) == :prod do
    defp formatters(file) do
      [
        Benchee.Formatters.Console
      ]
    end
  else
    defp formatters(file) do
      [
        {Benchee.Formatters.HTML, file: file},
        Benchee.Formatters.Console
      ]
    end
  end
end
