defmodule Nprx.Request do
  use GenServer, start: {__MODULE__, :start_link, []}, restart: :transient

  @timeout 100000
  @app_id Application.get_env(:nprx, :npr_app_id)
  @app_secret Application.get_env(:nprx, :npr_app_secret)

  def start_link(name),
    do: GenServer.start_link(__MODULE__, name, name: via_tuple(name))

  def init(name) do
    send(self(), {:authenticate, name})
    {:ok, %{name: name}, @timeout}
  end

  def get_stations(request) when is_binary(request),
    do: GenServer.call(via_tuple(request), :get_stations, @timeout)

  def get_stations(request) when is_pid(request),
    do: GenServer.call(request, :get_stations, @timeout)

  def handle_call(:get_stations, _from, state) do
    stations = NPRx.StationFinder.stations(state.token)
    {:reply, stations, state, @timeout}
  end

  def handle_info({:authenticate, name}, state) do
    state =
      case :ets.lookup(:request_state, name) do
        [] ->
          {:ok, token} = NPRx.HTTP.get_token()
          state = Map.put(state, :token, token)
          :ets.insert(:request_state, {name, state})
          state
        [{_key, state}] -> state
      end
    {:noreply, state, @timeout}
  end

  def handle_info(:timeout, state) do
    :ets.delete(:request_state, state.name)
    {:stop, {:shutdown, :timeout}, state}
  end

  def terminate({:shutdown, :timeout}, _state) do
    IO.puts("timed out")
    :ok
  end

  def terminate(_reason, _state) do
    IO.puts "terminating"
    :ok
  end

  def via_tuple(name),
    do: {:via, Registry, {Registry.Request, name}}
end
