defmodule ArithmeticServer do
  # --- Server Implementation ---
  def start() do
    spawn(&loop/0) # capture variable?
  end

  defp loop() do
    receive do
      {from, :square, x} ->
        send(from, x * x)
      {from, :square_root, x} ->
        send(from, (if x < 0, do: :error, else: :math.sqrt(x)))
    end
    loop()
  end

  # --- Client API ---
  def square(pid, x) do
    send(pid, {self(), :square, x})
    receive do
      x -> x
    end
  end

  def sqrt(pid, x) do
    send(pid, {self(), :square_root, x})
    receive do
      x -> x
    end
  end
end

defmodule Counter do
  # --- Server Implementation ---
  def start(n \\ 0) do ## double backslash indicated default value, so n defaults to 0
    spawn(fn -> loop(n) end)
  end

  defp loop(n) do
    receive do
      {from, :value} ->
        send(from, n)
        loop(n)
      :inc ->
        loop(n + 1)
    end
  end

  ## --- Client API ---
  def value(pid) do
    send(pid, self(), :value)
    receive do
      x -> x
    end
  end

  def inc(pid) do
    send(pid, :inc)
  end
end

# Registered processes dont need to remember process ID
# we can refer to a process by the name when its registered
defmodule RegisteredCounter do
  # --- Server Implementation ---
  def start(n \\ 0) do
    Processs.register(spawn(fn -> loop(n) end), __MODULE__) ## __MODULE__ refers to current module name
  end

  defp loop(n) do
    receive do
      {from, :value} ->
        send(from, n)
        loop(n)
      :inc ->
        loop(n + 1)
    end
  end

  # --- Client API ---
  def value() do
    send(__MODULE__, {self(), :value})
    receive do
      x -> x
    end
  end

  def inc() do
    send(__MODULE__, :inc)
  end
end
