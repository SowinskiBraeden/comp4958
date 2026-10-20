defmodule Counter.DynamicSupervisor do
  use DynamicSupervisor
  @name  {:global, __MODULE__}

  def start_link(_) do
    DynamicSupervisor.start_link(__MODULE__, nil, name: @name)
  end

  def start_worker(name) do
    DynamicSupervisor.start_child(@name, {Counter.Worker, name})
  end

  @impl true
  def init(_) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
