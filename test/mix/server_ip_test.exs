defmodule Bonfire.ServerIPTest do
  @moduledoc """
  `SERVER_IP` sets the address the web server listens on (bonfire-app#1594), for hosts that only have IPv4 or only IPv6, or to listen on localhost only behind a reverse proxy.

  These tests evaluate the real `config/runtime.exs` and read the endpoint's `http` options. The Cowboy branch is not covered: Cowboy is only compiled in when `PLUG_SERVER` or `TEST_WITH_BYPASS` is set at build time (see mix.exs).
  """
  use ExUnit.Case, async: false

  import ExUnit.CaptureIO

  @moduletag :backend

  @envs ["SERVER_IP", "PLUG_SERVER"]

  setup do
    previous = Map.new(@envs, &{&1, System.get_env(&1)})

    Enum.each(@envs, &System.delete_env/1)

    on_exit(fn ->
      Enum.each(previous, fn
        {name, nil} -> System.delete_env(name)
        {name, value} -> System.put_env(name, value)
      end)
    end)
  end

  defp endpoint_http_options do
    "config/runtime.exs"
    |> Config.Reader.read!(env: :test)
    |> get_in([:bonfire, Bonfire.Web.Endpoint, :http])
  end

  # keeps the config's console output out of the test output, and returns what it wrote to stderr
  defp endpoint_http_options_and_stderr do
    {{http, _stdout}, stderr} = with_io(:stderr, fn -> with_io(&endpoint_http_options/0) end)
    {http, stderr}
  end

  test "listens on the default address when SERVER_IP is unset" do
    {http, _stderr} = endpoint_http_options_and_stderr()

    assert http[:port]
    refute Keyword.has_key?(http, :ip)
  end

  test "treats an empty SERVER_IP as unset, without a warning" do
    System.put_env("SERVER_IP", "")

    {http, stderr} = endpoint_http_options_and_stderr()

    refute Keyword.has_key?(http, :ip)
    refute stderr =~ "SERVER_IP"
  end

  test "listens on the IPv4 address in SERVER_IP" do
    System.put_env("SERVER_IP", "127.0.0.1")

    {http, _stderr} = endpoint_http_options_and_stderr()

    assert http[:ip] == {127, 0, 0, 1}
  end

  test "listens on the IPv6 address in SERVER_IP" do
    System.put_env("SERVER_IP", "::")

    {http, _stderr} = endpoint_http_options_and_stderr()

    assert http[:ip] == {0, 0, 0, 0, 0, 0, 0, 0}
  end

  test "warns and listens on the default address when SERVER_IP is not an IP address" do
    System.put_env("SERVER_IP", "127.0.0.l")

    {http, stderr} = endpoint_http_options_and_stderr()

    refute Keyword.has_key?(http, :ip)
    assert stderr =~ "SERVER_IP"
    assert stderr =~ "127.0.0.l"
  end
end
