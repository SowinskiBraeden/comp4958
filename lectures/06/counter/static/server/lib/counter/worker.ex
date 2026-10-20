defmodule Counter.Worker do
  use GenServer

  @store  Counter.Store
  @name   {:global, __MODULE__}

  # client
  def start_link(n \\ 0) do
    GenServer.start_link(__MODULE__, n, name: @name)
  end

  def inc(amt \\ 1) do
    GenServer.cast(@name, {:inc, amt})
  end

  def value() do
    GenServer.call(@name, :value)
  end

  # server
  @impl true
  def init(arg) do
    {:ok, @store.get() || arg}
  end

  @impl true
  def handle_call(:value, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_cast({:inc, amt}, state) do
    {:noreply, state + amt}
  end

  # for demonstration only
  @impl true
  def handle_info(:reset, _state) do
    {:noreply, 0}
  end

  @impl true
  def terminate(_reason, state) do
    @store.put(state)
  end
end

