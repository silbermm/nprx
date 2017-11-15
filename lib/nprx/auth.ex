defmodule NPRx.Auth do
  use GenServer

  @name __MODULE__
  @app_id Application.get_env(:nprx, :npr_app_id)
  @app_secret Application.get_env(:nprx, :npr_app_secret)

  defstruct [:access_token, :expires_at]

  @doc false
  def start_link(opts \\ []) do
    opts = Keyword.put_new(opts, :name, @name)
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  @doc false
  def init(:ok) do
    {:ok, %__MODULE__{access_token: nil}}
  end

  @doc """
  Authenticates a client aka Application.
  """
  def authenticate_client(), do: GenServer.call(@name, {:authenticate_client}, 5000)

  @doc """
  Clears a previously cached authentication token
  """
  def clear(), do: GenServer.call(@name, {:clear}, 5000)

  def handle_call({:clear}, _from, _state) do
    {:reply, true, %__MODULE__{access_token: nil, expires_at: nil}}
  end

  @doc false
  def handle_call({:authenticate_client}, _from, state) do
    case state.access_token do
      nil -> send_auth_update_state(state)
      _ ->
        if is_expired?(state) do
          send_auth_update_state(state)
        else
          {:reply, {:ok, state.access_token}, state}
        end
    end
  end

  defp send_auth_update_state(state) do
    result = get_token()
    state = update_state(result, state)
    {:reply, result, state}
  end

  defp update_state({:ok, token}, _state), do: %__MODULE__{access_token: token, expires_at: expires()}
  defp update_state(_result, state), do: state

  defp parse_body({:ok, %HTTPoison.Response{status_code: 200, body: body}}) do
    token =
        body
        |> decode_body
        |> Map.get("access_token", "")
    {:ok, token}
  end
  defp parse_body({:ok, %HTTPoison.Response{body: body}}) do
    {:error, Poison.decode!(body)}
  end
  defp parse_body({:error, %HTTPoison.Error{reason: reason}}), do: {:error, reason}

  defp expires() do
    NaiveDateTime.utc_now
    |> NaiveDateTime.add(200)
  end

  defp is_expired?(state) do
    NaiveDateTime.utc_now
    |> NaiveDateTime.compare(state.expires_at)
    |> case do
      :gt -> 
        IO.puts "greater than"
        true
      :lt -> 
        IO.puts "Less than"
        false
      :eq -> true
    end
  end

  defp get_token() do
    "https://api.npr.org/authorization/v2/token"
    |> HTTPoison.post(auth_body, %{"Content-type" => "application/x-www-form-urlencoded"})
    |> parse_body
  end

  defp decode_body(body) do
    body
    |> Poison.decode
    |> case do
      {:ok, decoded} -> decoded
      {:error, reason} -> %{}
      other -> %{}
    end
  end

  defp auth_body() do
    ["grant_type=client_credentials",
     "&client_id=#{URI.encode_www_form(@app_id)}",
     "&client_secret=#{URI.encode_www_form(@app_secret)}"]
    |> Enum.join
  end

end
