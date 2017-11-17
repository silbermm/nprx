defmodule NPRx.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      {NPRx.HTTP.Worker, []},
      {NPRx.Auth, []},
    ]

    opts = [strategy: :one_for_one, name: NPRx.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
