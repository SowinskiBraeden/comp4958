defmodule Counter.Worker do
  use GenServer
  @table     Counter.Table

  # client
  def start_link(name) do
    GenServer.start_link(__MODULE__, name, name: via(name))
  end

  def value(name) do
    GenServer.call(via(name), :value)
  end

  def inc(name, amt \\ 1) do
    GenServer.cast(via(name), {:inc, amt})
  end

  defp via(name) do
    {:global, name}
  end

  # server
  @impl true
  def init(arg) do
    name = {__MODULE__, arg}
    value = case :ets.lookup(@table, name) do
      [] -> 0
      [{_, v}] -> v
    end
    {:ok, {name, value}}
  end

  @impl true
  def handle_call(:value, _from, {_, value} = state) do
    {:reply, value, state}
  end

  @impl true
  def handle_cast({:inc, amt}, {name, value}) do
    {:noreply, {name, value + amt}}
  end

  @impl true
  def terminate(_reason, state) do
    :ets.insert(@table, state)
  end
end
