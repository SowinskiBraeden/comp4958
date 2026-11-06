defmodule Chat.Application do
  # The application supervises the one authoritative chat server. TCP proxy
  # instances are started separately and may live on other connected nodes.
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    # The application owns these tables, so they survive a Chat.Server restart.
    :ets.new(Chat.Nicknames, [:named_table, :public])
    :ets.new(Chat.Clients, [:named_table, :public])

    children = [
      Chat.Server
    ]

    opts = [strategy: :one_for_one, name: Chat.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
