defmodule Card.Worker do
  use GenServer

  @registry Card.Registry
  @table Card.Table

  ### Client API ###
  def start_link(name) do
    GenServer.start_link(__MODULE__, name, name: via(name))
  end

  def new(name) do
    GenServer.cast(via(name), :new)
  end

  def shuffle(name) do
    GenServer.cast(via(name), :shuffle)
  end

  def count(name) do
    GenServer.call(via(name), :count)
  end

  def deal(name, n \\ 1) do
    GenServer.call(via(name), {:deal, n})
  end

  # wrap the name in a triple to use the Registry to get the
  # process ID by name
  defp via(name) do
    {:via, Registry, {@registry, {__MODULE__, name}}}
  end

  ### Server Impl ###
  defp fresh() do
    values = Enum.map(2..10, &Integer.to_string/1) ++ ["J", "Q", "K", "A"]
    suits = ["♣", "♦", "♥", "♠"]

    for v <- values, f <- suits, do: v <> f
  end

  @impl true
  def init(arg) do
    key = {__MODULE__, arg}

    deck =
      case :ets.lookup(@table, key) do
        [] -> fresh()
        [{_, d}] -> d
      end

    IO.puts("Card.Worker #{inspect(arg)} started/re-started with pid #{inspect(self())}")
    {:ok, {key, deck}}
  end

  @impl true
  def handle_cast(:new, {key, _deck}) do
    # {:noreply, new_state}
    {:noreply, {key, fresh()}}
  end

  @impl true
  def handle_cast(:shuffle, {key, deck}) do
    # {:noreply, new_state}
    {:noreply, {key, Enum.shuffle(deck)}}
  end

  @impl true
  def handle_call(:count, _from, {_key, deck} = state) do
    # {:reply, actual_reply, new_state}
    {:reply, length(deck), state}
  end

  @impl true
  def handle_call({:deal, n}, _from, {key, deck}) when is_integer(n) do
    case n do
      _ when n < 0 ->
        # {:reply, actual_reply, new_state}
        {:reply, {:error, "Cannot deal negative number of cards"}, {key, deck}}

      _ when n > length(deck) ->
        # {:reply, actual_reply, new_state}
        {:reply, {:error, "Insufficient cards in deck to deal"}, {key, deck}}

      _ ->
        {d, r} = Enum.split(deck, n)
        # {:reply, actual_reply, new_state}
        {:reply, {:ok, d}, {key, r}}
    end
  end

  # save state to the term table so a restart can recover it
  @impl true
  def terminate(_reason, state) do
    :ets.insert(@table, state)
  end
end
