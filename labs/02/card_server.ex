defmodule CardServer do
  # --- Server Implementation ---
  def start() do
    spawn(fn -> loop(new()) end)
  end

  defp new() do
    values = Enum.map(2..10, &Integer.to_string/1) ++ ["J", "Q", "K", "A"]
    suits  = ["\u2663", "\u2666", "\u2665", "\u2660"]

    for v <- values, f <- suits, do: v <> f
  end

  defp deal(from, deck, n) do
    case n do
      _ when n < 0 ->
        send(from, {:error, "Cannot deal negative number of cards"})
        deck

      _ when n > length(deck) ->
        send(from, {:error, "Insufficient cards in deck to deal"})
        deck

      _ ->
        {d, r} = Enum.split(deck, n)
        send(from, {:ok, d})
        r
    end
  end

  defp loop(deck) do
    receive do
      :new ->
        loop(new())

      :shuffle ->
        loop(Enum.shuffle(deck))

      {from, :count} ->
        send(from, length(deck))
        loop(deck)

      {from, :deal, n} ->
        remaining = deal(from, deck, n)
        loop(remaining)
    end
  end

  # --- Client API ---
  def new(pid) do
    send(pid, :new)
  end

  def shuffle(pid) do
    send(pid, :shuffle)
  end

  def count(pid) do
    send(pid, {self(), :count})
    receive do
      x -> x
    end
  end

  def deal(pid, n \\ 1) do
    send(pid, {self(), :deal, n})
    receive do
      x -> x
    end
  end
end
