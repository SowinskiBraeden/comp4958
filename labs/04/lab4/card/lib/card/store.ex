defmodule Card.Store do
  use GenServer

  # client
  def start_link(file) do
    GenServer.start_link(__MODULE__, file, name: __MODULE__)
  end

  def put(value) do
    GenServer.call(__MODULE__, {:put, value})
  end

  def get() do
    GenServer.call(__MODULE__, :get)
  end

  # server
  @impl true
  def init(file) do
    {:ok, file}
  end

  @impl true
  def handle_call(:get, _from, file) do
    reply =
      case File.read(file) do
        {:ok, content} -> :erlang.binary_to_term(content)
        _ -> nil
      end

    {:reply, reply, file}
  end

  @impl true
  def handle_call({:put, value}, _from, file) do
    reply = File.write(file, :erlang.term_to_binary(value))
    {:reply, reply, file}
  end
end
