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
  Authenticates a client (A.K.A Application) and caches the token for 5 minutes.
  """
  def authenticate_client(), do: GenServer.call(@name, {:authenticate_client}, 5000)

  @doc """
  Clears a previously cached authentication token
  """
  def clear(), do: GenServer.call(@name, {:clear}, 5000)

  @doc false
  def handle_call({:clear}, _from, _state) do
    {:reply, true, %__MODULE__{access_token: nil, expires_at: nil}}
  end

  @doc false
  def handle_call({:authenticate_client}, _from, state) do
    case state.access_token do
      nil -> authenticate(state)
      _ ->
        if is_expired?(state) do
          authenticate(state)
        else
          {:reply, {:ok, state.access_token}, state}
        end
    end
  end

  defp authenticate(state) do
    token_result = NPRx.HTTP.get_token()
    state = update_state(token_result, state)
    {:reply, token_result, state}
  end

  defp update_state({:ok, token}, _state), do: %__MODULE__{access_token: token, expires_at: expires()}
  defp update_state({:error, reason}, state), do: state

  defp expires() do
    NaiveDateTime.utc_now
    |> NaiveDateTime.add(300)
  end

  defp is_expired?(state) do
    IO.inspect state
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
end
