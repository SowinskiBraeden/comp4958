### Streams

0..1_000_000 |> Enum.map(& &1 * &1) |> Enum.filter(& rem(&1, 8) == 0) |> Enum.sum
#                        & &1 * &1 is equivalent to
#                        fn x -> x * x end

0..1_000_000 |> Steam.map(& &1 * &1) |> Steam.filter(& rem(&1, 8) == 0) |> Enum.sum

fibs = Stream.unfold({0, 1}, fn {a, b} -> {a, {b, a+b}} end)
fibs |> Enum.take(20);

# fizzbuzz infstream
nats = Stream.iterate(1, & &1 + 1)
#      Stream.iterate(1, fn x -> x + 1) is an inf stream because we can take up to n with no limit
nats |> Enum.take(10)

fizz = Stream.cycle(["", "", "fizz"])
fizz |> Enum.take(10)
buzz = Stream.cycle(["", "", "", "", "buzz"])
buzz |> Enum.take(10)

fizzbuzz = Stream.zip_with([nats, fizz, buzz], fn [n, f, b] ->
  if f == "" && b == "", do: n,
  else: f <> b # concat f with b
end)
