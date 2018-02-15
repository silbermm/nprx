defmodule Nprx.RequestSupervisor do
  use Supervisor

  def start_link(_options),
    do: Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)

  def init(:ok) do
    :ets.new(:request_state, [:public, :named_table])
    Supervisor.init([Nprx.Request], strategy: :simple_one_for_one)
  end

  def new_request(fun) when is_function(fun) do
    identifier = generate_identifier
    with {:ok, pid} <- Supervisor.start_child(__MODULE__, [identifier]) do
      fun.({pid, identifier})
      end_request(identifier)
    else
      {:error, {:already_started, pid}} -> 
        fun.({pid, identifier})
        end_request(identifier)
      _ -> :error
    end
  end

 # def new_request(client_id, client_secret) when is_binary(client_id) and is_binary(client_secret) do

  #end

  def new_request() do
    identifier = generate_identifier
    with {:ok, pid} <- Supervisor.start_child(__MODULE__, [identifier]) do
      {:ok, pid, identifier}
    else
      err -> err
    end
  end

  def end_request(named_request) do
    :ets.delete(:request_state, named_request)
    Supervisor.terminate_child(__MODULE__, pid_from_name(named_request))
  end

  defp pid_from_name(named_request) do
    named_request
    |> Nprx.Request.via_tuple
    |> GenServer.whereis
  end

  defp generate_identifier() do
    :crypto.strong_rand_bytes(5) |> Base.url_encode64
  end
end
