defmodule Arithmetic.Worker do
  use GenServer

  def start() do
    GenServer.start(__MODULE__, nil)
  end

  ### Server Impl ###
  @impl true
  def init(_arg) do
    {:ok, nil}
  end

  @impl true
  def handle_cast({:square, x, from}, state) do
    # The server dispatches work asynchronously, so workers handle casts and
    # reply directly to the client that made the original GenServer.call/2.
    GenServer.reply(from, {self(), x * x})
    {:noreply, state}
  end

  @impl true
  def handle_cast({:sqrt, x, from}, state) do
    Process.sleep(2000)
    GenServer.reply(from, {self(), if(x < 0, do: :error, else: :math.sqrt(x))})
    {:noreply, state}
  end
end

defmodule Arithmetic.Server do
  use GenServer

  ### Client API ###
  def start(n) do
    GenServer.start(__MODULE__, n, name: __MODULE__)
  end

  def square(x) do
    GenServer.call(__MODULE__, {:square, x})
  end

  def sqrt(x) do
    GenServer.call(__MODULE__, {:sqrt, x})
  end

  ### Server Impl ###
  @impl true
  def init(n) do
    workers =
      Enum.map(1..n, fn _ ->
        {:ok, pid} = Arithmetic.Worker.start()
        IO.inspect(pid)
        pid
      end)

    {:ok, {workers, 0}}
  end

  @impl true
  def handle_call({:square, x}, from, {workers, index}) do
    worker = Enum.at(workers, index)

    GenServer.cast(worker, {:square, x, from})

    next = rem(index + 1, length(workers))
    # Do not reply here; the selected worker replies to `from` after the cast.
    {:noreply, {workers, next}}
  end

  @impl true
  def handle_call({:sqrt, x}, from, {workers, index}) do
    worker = Enum.at(workers, index)

    GenServer.cast(worker, {:sqrt, x, from})

    next = rem(index + 1, length(workers))
    {:noreply, {workers, next}}
  end
end
