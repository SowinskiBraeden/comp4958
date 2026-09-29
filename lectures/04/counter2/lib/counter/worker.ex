defmodule Counter.Worker do
  use GenServer

  # client
  def start_link(name) do
      GenServer.start_link(__MODULE__, nil, name: name)
  end

  def inc(name, amt \\ 1) do
      GenServer.cast(name, {:inc, amt})
  end

  def value(name) do
    GenServer.call(name, :value)
  end

  # server impl
  @impl true
  def init(_arg) do
    {:ok, 0}
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
end
