defmodule Counter.Worker do
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
end
