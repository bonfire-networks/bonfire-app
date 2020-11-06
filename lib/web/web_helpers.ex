defmodule CommonsPub.Core.WebHelpers do
  import Phoenix.LiveView
  require Logger

  def strlen(x) when is_nil(x), do: 0
  def strlen(%{} = obj) when obj == %{}, do: 0
  def strlen(%{}), do: 1
  def strlen(x) when is_binary(x), do: String.length(x)
  def strlen(x) when is_list(x), do: length(x)
  def strlen(x) when x > 0, do: 1
  # let's say that 0 is nothing
  def strlen(x) when x == 0, do: 0

  @doc "Returns a value, or a fallback if not present"
  def e(key, fallback) do
    if(strlen(key) > 0) do
      key
    else
      fallback
    end
  end

  @doc "Returns a value from a map, or a fallback if not present"
  def e(map, key, fallback) do
    if(is_map(map)) do
      # attempt using key as atom or string
      map_get(map, key, fallback)
    else
      fallback
    end
  end

  @doc "Returns a value from a nested map, or a fallback if not present"
  def e(map, key1, key2, fallback) do
    e(e(map, key1, %{}), key2, fallback)
  end

  def e(map, key1, key2, key3, fallback) do
    e(e(map, key1, key2, %{}), key3, fallback)
  end

  def e(map, key1, key2, key3, key4, fallback) do
    e(e(map, key1, key2, key3, %{}), key4, fallback)
  end

  def is_numeric(str) do
    case Float.parse(str) do
      {_num, ""} -> true
      _ -> false
    end
  end

  def to_number(str) do
    case Float.parse(str) do
      {num, ""} -> num
      _ -> 0
    end
  end

  def map_error({:error, value}, fun), do: fun.(value)
  def map_error(other, _), do: other

  def replace_error({:error, _}, value), do: {:error, value}
  def replace_error(other, _), do: other

  def replace_nil(nil, value), do: value
  def replace_nil(other, _), do: other


  @doc """
  Attempt geting a value out of a map by atom key, or try with string key, or return a fallback
  """
  def map_get(map, key, fallback) when is_atom(key) do
    Map.get(map, key, map_get(map, Atom.to_string(key), fallback))
  end

  @doc """
  Attempt geting a value out of a map by string key, or try with atom key (if it's an existing atom), or return a fallback
  """
  def map_get(map, key, fallback) when is_binary(key) do
    Map.get(
      map,
      key,
      Map.get(
        map,
        Recase.to_camel(key),
        Map.get(
          map,
          maybe_str_to_atom(key),
          Map.get(
            map,
            maybe_str_to_atom(Recase.to_camel(key)),
            fallback
          )
        )
      )
    )
  end

  def map_get(map, key, fallback) do
    Map.get(map, key, fallback)
  end

  def maybe_str_to_atom(str) do
    try do
      String.to_existing_atom(str)
    rescue
      ArgumentError -> str
    end
  end

  def input_to_atoms(data) do
    data |> Map.new(fn {k, v} -> {maybe_str_to_atom(k), v} end)
  end

  def random_string(length) do
    :crypto.strong_rand_bytes(length) |> Base.url_encode64() |> binary_part(0, length)
  end

  def r(html), do: Phoenix.HTML.raw(html)

  def markdown(html), do: r(markdown_to_html(html))

  def markdown_to_html(nil) do
    nil
  end

  def markdown_to_html(content) do
    content
    |> Earmark.as_html!()
    |> external_links()
  end

  # open outside links in a new tab
  def external_links(content) do
    Regex.replace(~r/(<a href=\"http.+\")>/U, content, "\\1 target=\"_blank\">")
  end

  def date_from_now(date) do
    with {:ok, from_now} <-
           Timex.shift(date, minutes: -3)
           |> Timex.format("{relative}", :relative) do
      from_now
    else
      _ ->
        ""
    end
  end


  @doc """
  This initializes the socket assigns
  """
  def init_assigns(
        _params,
        %{
          # "auth_token" => auth_token,
          "account_id" => account_id,
          "username" => username,
          "current_user" => current_user,
          "_csrf_token" => csrf_token
        } = _session,
        %Phoenix.LiveView.Socket{} = socket
      ) do
    # Logger.info(session_preloaded: session)
    socket
    |> assign(:csrf_token, csrf_token)
    # |> assign(:auth_token, auth_token)
    |> assign(:account_id, account_id)
    |> assign(:username, username)
    |> assign(:current_user, current_user)
    |> assign(:static_changed, static_changed?(socket))
    |> assign(:search, "")
    |> assign(:toggle_post, false)
  end

  def init_assigns(
        _params,
        %{
          # "auth_token" => auth_token,
          "account_id" => account_id,
          "username" => username,
          "_csrf_token" => csrf_token
        } = _session,
        %Phoenix.LiveView.Socket{} = socket
      ) when is_binary(account_id) do
    # Logger.info(session_load: session)

    current_user = if is_binary(username) and Kernel.function_exported?(CommonsPub.Me.Users, :by_username, 1) do
      with {:ok, user} <- CommonsPub.Me.Users.by_username(username) do
        user
      else _ ->
        socket |> redirect(to: "/logout")
      end

    else
      # Fake.user_live()
    end
    # IO.inspect(current_user)

    socket
    |> assign(:csrf_token, csrf_token)
    # |> assign(:auth_token, auth_token)
    |> assign(:account_id, account_id)
    |> assign(:username, username)
    |> assign(:current_user, current_user)
    |> assign(:static_changed, static_changed?(socket))
    |> assign(:search, "")
    |> assign(:toggle_post, false)
  end

  def init_assigns(
        _params,
        %{
          "_csrf_token" => csrf_token
        } = _session,
        %Phoenix.LiveView.Socket{} = socket
      ) do
    socket
    |> assign(:csrf_token, csrf_token)
    |> assign(:static_changed, static_changed?(socket))
    |> assign(:current_user, nil)
    |> assign(:search, "")
  end

  def init_assigns(_params, _session, %Phoenix.LiveView.Socket{} = socket) do
    socket
    |> assign(:current_user, nil)
    |> assign(:search, "")
    |> assign(:static_changed, static_changed?(socket))
  end

  def paginate_next(fetch_function, %{assigns: assigns} = socket) do
    {:noreply, socket |> assign(page: assigns.page + 1) |> fetch_function.(assigns)}
  end


end
