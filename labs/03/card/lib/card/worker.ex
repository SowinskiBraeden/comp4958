defmodule Card.Worker do
  use GenServer

  ### Client API ###
  def start() do
    GenServer.start(__MODULE__, nil, name: __MODULE__)
  end

  def new() do
    GenServer.cast(__MODULE__, :new)
  end

  def shuffle() do
    GenServer.cast(__MODULE__, :shuffle)
  end

  def count() do
    GenServer.call(__MODULE__, :count)
  end

  def deal(n \\ 1) do
    GenServer.call(__MODULE__, {:deal, n})
  end

  ### Server Impl ###
  defp fresh() do
    values = Enum.map(2..10, &Integer.to_string/1) ++ ["J", "Q", "K", "A"]
    suits = ["\u2663", "\u2666", "\u2665", "\u2660"]

    for v <- values, f <- suits, do: v <> f
  end

  @impl true
  def init(_arg) do
    {:ok, fresh()}
  end

  @impl true
  def handle_cast(:new, _state) do
    # {:noreply, new_state}
    {:noreply, fresh()}
  end

  @impl true
  def handle_cast(:shuffle, state) do
    # {:noreply, new_state}
    {:noreply, Enum.shuffle(state)}
  end

  @impl true
  def handle_call(:count, _from, state) do
    # {:reply, actual_reply, new_state}
    {:reply, length(state), state}
  end

  @impl true
  def handle_call({:deal, n}, _from, state) do
    case n do
      _ when n < 0 ->
        # {:reply, actual_reply, new_state}
        {:reply, {:error, "Cannot deal negative number of cards"}, state}

      _ when n > length(state) ->
        # {:reply, actual_reply, new_state}
        {:reply, {:error, "Insufficient cards in deck to deal"}, state}

      _ ->
        {d, r} = Enum.split(state, n)
        # {:reply, actual_reply, new_state}
        {:reply, {:ok, d}, r}
    end
  end
end
