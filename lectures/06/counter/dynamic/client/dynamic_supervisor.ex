defmodule Counter.DynamicSupervisor do
  @name  {:global, __MODULE__}

  def start_link(_) do
    DynamicSupervisor.start_link(__MODULE__, nil, name: @name)
  end

  def start_worker(name) do
    DynamicSupervisor.start_child(@name, %{
      id: Counter.Worker, 
      start: {Counter.Worker, :start_link, [name]}})
  end
end
