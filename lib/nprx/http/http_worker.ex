defmodule NPRx.HTTP.Worker do
  use GenServer

  @name __MODULE__

  def start_link(opts) do
    opts = Keyword.put_new(opts, :name, @name)
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok), do: {:ok, %{}}

  def get_async(url, auth) do
    GenServer.call(@name, {:get_async, url, auth}, 5000)
  end

  def get(url, auth) do
    GenServer.call(@name, {:get, url, auth}, 5000)
  end

  def handle_call({:get_async, url, auth}, {pid, tag} = from, state) do
    {:ok, handler} = NPRx.HTTP.AsyncHandler.start_link(self)
    url
    |> make_call(auth, stream_to: handler)
    |> case do
      {:ok, %HTTPoison.AsyncResponse{id: id}} = res ->
        {:reply, res, Map.put(state, id, %{resolved: false})}
      {:error, %HTTPoison.Error{reason: reason}} = res ->
        {:reply, res, state}
    end
  end

  def handle_call({:get, url, auth}, _from, state) do
    response =
      url
      |> make_call(auth)
    {:reply, response, state}
  end

  def handle_info(%{id: id, status_code: status_code} = res, state) do
    current_request = Map.get(state, id)
    {:noreply, %{state | id => Map.put(current_request, :response, res)}}
  end

  defp make_call(url, auth, opts \\ []) do
    opts = Keyword.merge(opts, hackney: [pool: :default], timeout: 2000)
    HTTPoison.get(url, %{"Authorization" => "Bearer #{auth}"}, opts)
  end
end
