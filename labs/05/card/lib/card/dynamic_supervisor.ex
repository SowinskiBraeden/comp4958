defmodule Card.DynamicSupervisor do
  use DynamicSupervisor

  def start_link(_) do
    DynamicSupervisor.start_link(__MODULE__, nil)
  end

  def start_worker(name) do
    DynamicSupervisor.start_child(
      {:via, PartitionSupervisor, {Card.DynamicSupervisors, self()}},
      {Card.Worker, name}
    )
  end

  @impl true
  def init(_) do
    IO.puts("Card.DynamicSupervisor started/re-started with pid #{inspect(self())}")
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
