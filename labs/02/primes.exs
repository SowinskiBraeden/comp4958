defmodule Primes do
  defp sieve([], acc, _) do
    Enum.reverse(acc)
  end

  defp sieve([h | t], acc, n) do
    if h * h > n do
      Enum.reverse(acc) ++ [h | t]
    else
      sieve(
        Enum.filter(t, fn x -> rem(x, h) != 0 end),
        [h | acc],
        n)
    end
  end

  def primes(n) do
    l = Enum.to_list(2..n)
    sieve(l, [], n)
  end

  defp largest_permutation_set(p) do
    p |> Enum.group_by(fn x -> x
      |> Integer.to_string()
      |> String.to_charlist()
      |> Enum.sort() end)
      |> Map.values()
      |> Enum.max_by(&length/1)
  end

  def run(n, d) do
    p = primes(n)
    p = Enum.filter(p, fn x ->
      String.length(Integer.to_string(x)) >= d
    end)

    IO.puts(length(p))
    IO.puts(length(largest_permutation_set(p)))
  end
end

Primes.run(1_000_000, 6);
