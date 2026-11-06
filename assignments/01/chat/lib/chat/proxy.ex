defmodule Chat.Proxy do
  @moduledoc """
  TCP acceptor that creates one `Chat.Proxy.Worker` per connection.

  Instances are deliberately unregistered, allowing several proxies (and
  proxies on different connected nodes) to serve the global chat server.
  """

  use GenServer
  require Logger

  @doc "Starts an unregistered proxy listening on `port` (default 6666)."
  def start(port \\ 6666) do
    GenServer.start(__MODULE__, port)
  end

  @impl true
  def init(port) do
    opts = [:binary, active: false, packet: :line, reuseaddr: true]
    {:ok, listen} = :gen_tcp.listen(port, opts)
    {:ok, {_address, actual_port}} = :inet.sockname(listen)
    Logger.info("chat proxy listening on TCP port #{actual_port}")
    send(self(), :accept)
    {:ok, listen}
  end

  @impl true
  def handle_info(:accept, listen) do
    {:ok, socket} = :gen_tcp.accept(listen)
    {:ok, worker} = Chat.Proxy.Worker.start(socket)

    :ok = :gen_tcp.controlling_process(socket, worker)
    send(worker, :socket_ready)
    Logger.info("client connected: #{inspect(socket)}")

    send(self(), :accept)
    {:noreply, listen}
  end

  @impl true
  def terminate(_reason, listen) do
    :gen_tcp.close(listen)
  end
end
