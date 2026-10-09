defmodule Counter.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  @registry Counter.Registry
  @table	Counter.Table

  use Application

  @impl true
  def start(_type, _args) do
	children = [
	  {Registry, name: @registry, keys: :unique}, # recall same as {Registry, [name: @registry, keys: :unique]}
	  # Starts a worker by calling: Counter.Worker.start_link(arg)
	  # {DynamicSupervisor, name: Counter.DynamicSupervisor, strategy: :one_for_one}
	  Counter.DynamicSupervisor # no argument passed so we can just use this
	]

	:ets.new(@table, [:named_table, :public])
	# See https://hexdocs.pm/elixir/Supervisor.html
	# for other strategies and supported options
	opts = [strategy: :one_for_one, name: Counter.Supervisor]
	Supervisor.start_link(children, opts)
  end
end
