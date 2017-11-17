defmodule NPRx.HTTP.AsyncHandler do
  use GenServer

  @state %{from: nil, id: nil, status_code: 0, headers: [], chunk: "", resolved: false}

  def start_link(from, opts \\ []) do
    GenServer.start_link(__MODULE__, {:ok, from}, opts)
  end

  def init({:ok, from}) do
    state = @state
    {:ok, %{state | from: from}}
  end

  def handle_info(%HTTPoison.AsyncStatus{code: code, id: id}, state) do
    {:noreply, %{state | status_code: code, id: id}}
  end
  def handle_info(%HTTPoison.AsyncHeaders{headers: headers, id: _id}, state) do
    {:noreply, %{state | headers: headers}}
  end
  def handle_info(%HTTPoison.AsyncChunk{chunk: chunk, id: _id}, state) do
    chunk = state.chunk <> chunk
    {:noreply, %{state | chunk: chunk}}
  end
  def handle_info(%HTTPoison.AsyncEnd{id: _id}, state) do
    IO.puts("done processing async request")
    IO.inspect state.from
    state = %{state | resolved: true}
    send(state.from, state)
    {:stop, :normal, state}
  end
end
