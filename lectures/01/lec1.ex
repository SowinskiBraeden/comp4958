defmodule Lec1 do
  def fact(n) do
    if n <= 0 do
      1
    else
      n * fact(n - 1)
    end
  end

  def fact2(0) do 1 end # multi-clause function
  def fact2(n) do n * fact2(n - 1) end

  def fact3(n) when n <= 0 do 1 end # using guard
  def fact3(n) do  n * fact3(n - 1) end

  # What on earth is going on?
  # do: with commas eliminates end?
  def fact4(n) when n <= 0, do: 1
  def fact4(n), do: n * fact3(n - 1)

  # private functions to this module, i.e. no Lec1.fact5 on these
  defp fact5(n, acc) when n <= 0, do: acc
  defp fact5(n, acc), do: fact5(n - 1, n * acc)

  # we can call this function internally though
  def fact5(n), do: fact5(n, 1)

  # ------- pattern matching -------

  def dedup(l) do
    case l do
      [x, x | rest] -> dedup([x | rest])
      [x | rest] -> [x | dedup(rest)]
      _ -> l
    end
  end

  # or matching within pattern matching
  def dedup1(l) do
    case l do
      [x | rest = [x | _]] -> dedup(rest)
      [x | rest] -> [x | dedup(rest)]
      _ -> l
    end
  end

  # -------
  defp fizzbuzz_print(n) do
    cond do
      rem(n, 15) == 0 -> IO.puts("fizzbuzz")
      rem(n, 5) == 0 -> IO.puts("buzz")
      rem(n, 3) == 0 -> IO.puts("fizz")
      true -> IO.puts(n)
    end
  end

  defp fizzbuzz(i, n) when i > n, do: :ok
  defp fizzbuzz(i, n) do
    fizzbuzz_print(i)
    fizzbuzz(i + 1, n)
  end

  def fizzbuzz(n), do: fizzbuzz(1, n)

  # --------
  def qsort([]), do: []
  def qsort([h | t]), do: qsort( Enum.filter(t, &(&1 < h)) ) ++
    [h] ++ qsort ( Enum.filter(t, &(&1 > h)) )
end

# why the above works
# imagine the following
if 1 < 2 do "OK" else "BAD" end

# is similar to
if(1 < 2, do: "OK", else: "BAD")

# consider a key-word list
[{:a, 1}, {:b, 2}]

# so do: ok is esentially a key-word list
if(1 < 2, [do: "OK", else: "BAD"])

# somehow this works
