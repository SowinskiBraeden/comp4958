defmodule Card.Application do
  @moduledoc false

  @registry Card.Registry
  @table Card.Table

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Registry, name: @registry, keys: :unique},
      {PartitionSupervisor,
       name: Card.DynamicSupervisors, partitions: 4, child_spec: Card.DynamicSupervisor}
    ]

    :ets.new(@table, [:named_table, :public])

    opts = [strategy: :one_for_one, name: Card.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
