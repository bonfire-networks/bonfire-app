defmodule Bonfire.ActivityPub.IntegrationTest do
  use Bonfire.ConnCase
  import Tesla.Mock

  # TODO: move this into fixtures
  setup do
    mock(fn
      %{method: :get, url: "https://kawen.space/users/karen"} ->
        json(%{
          "@context" => [
            "https://www.w3.org/ns/activitystreams",
            "https://kawen.space/schemas/litepub-0.1.jsonld",
            %{"@language" => "und"}
          ],
          "attachment" => [
            %{
              "name" => "gf",
              "type" => "PropertyValue",
              "value" =>
                "<a rel=\"me\" href=\"https://nulled.red/@waifu\">https://nulled.red/@waifu</a>"
            }
          ],
          "discoverable" => false,
          "endpoints" => %{
            "oauthAuthorizationEndpoint" => "https://kawen.space/oauth/authorize",
            "oauthRegistrationEndpoint" => "https://kawen.space/api/v1/apps",
            "oauthTokenEndpoint" => "https://kawen.space/oauth/token",
            "sharedInbox" => "https://kawen.space/inbox",
            "uploadMedia" => "https://kawen.space/api/ap/upload_media"
          },
          "followers" => "https://kawen.space/users/karen/followers",
          "following" => "https://kawen.space/users/karen/following",
          "icon" => %{
            "type" => "Image",
            "url" =>
              "https://kawen.space/media/39fb9c0661e7de08b69163fee0eb99dee5fa399f2f75d695667cabfd9281a019.png?name=MKIOQWLTKDFA.png"
          },
          "id" => "https://kawen.space/users/karen",
          "image" => %{
            "type" => "Image",
            "url" =>
              "https://kawen.space/media/e05c7271-cd93-472a-97bd-46367f9709d7/CC0E8BA674C6519E9749C29C8883C30F3E348D6DAC558C13E4018BA385F7DA5C.jpeg"
          },
          "inbox" => "https://kawen.space/users/karen/inbox",
          "manuallyApprovesFollowers" => false,
          "name" => "叶恋 (妹)",
          "outbox" => "https://kawen.space/users/karen/outbox",
          "preferredUsername" => "karen",
          "publicKey" => %{
            "id" => "https://kawen.space/users/karen#main-key",
            "owner" => "https://kawen.space/users/karen",
            "publicKeyPem" =>
              "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA5FUojZbzUpD6L1Kof1gr\nh7GMSKd/N36FiekhhyDBAhtXgwEFgUWkiGLyDrNPP6RFFD/37FuZlq9JWSAonEHL\nbE4freE/FcuBP84AWQl/ZEm8BPCYVlHwALFEo13Gxg/VMetN37By0H7O7Lmb5JV4\nVgujqMaoNss03fwZARGd0LMLokN5KJExt7e1bsAqZOvI/xOBF1XlSRiHkco4OUGZ\nYjhoNbCKQtL995hGo14JlNd3QZI5RcBU47SqEuUYvgJXlyrVEKpqozBsFpGkh4/+\n9ck31bG50V3mLTL2SUthUdX9r8DgJVsxFYSb/rRMyPcCZAH8RD3FJH5deRtH1KJy\n7wIDAQAB\n-----END PUBLIC KEY-----\n\n"
          },
          "summary" =>
            "Zakladatelka kawen.space, vývojářka Pleromy a MoodleNetu, kočička. Umím mňoukat v pěti jazycích a Super Metroid dohraju tak za hodinu. A dělám dobrý kari. <a class=\"hashtag\" data-tag=\"kawen\" href=\"https://kawen.space/tag/kawen\" rel=\"tag ugc\">#kawen</a>​",
          "tag" => [],
          "type" => "Person",
          "url" => "https://kawen.space/users/karen"
        })
    end)

    :ok
  end

  test "fetch users from AP API" do
    user = fake_user!()

    conn =
      build_conn()
      |> get("/pub/actors/#{user.character.username}")
      |> response(200)
      |> Jason.decode!

    assert conn["preferredUsername"] == user.character.username
    assert conn["name"] == user.profile.name
    assert conn["summary"] == user.profile.summary
  end

  test "remote actor creation" do
    {:ok, actor} = ActivityPub.Actor.get_or_fetch_by_ap_id("https://kawen.space/users/karen")
    assert {:ok, user} = Bonfire.Me.Identity.Users.ActivityPub.by_username(actor.username)
  end
end
