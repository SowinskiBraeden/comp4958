defmodule Counter.Worker do
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
end

