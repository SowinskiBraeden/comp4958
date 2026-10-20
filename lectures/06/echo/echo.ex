defmodule Echo.Active do
  def start(port \\ 6666) do
    opts = [:binary, active: true, packet: :line, reuseaddr: true]
    {:ok, listen} = :gen_tcp.listen(port, opts)
    accept(listen)
  end

  def accept(listen) do
    {:ok, socket} = :gen_tcp.accept(listen)  # data delivered as messages in the mailbox of the
                                             # process that calls accept
    spawn(fn -> accept(listen) end)
    loop(socket)
  end

  defp loop(socket) do
    receive do
      {:tcp, ^socket, data} ->
        :gen_tcp.send(socket, data)
        loop(socket)
      {:tcp_closed, ^socket} ->
        :gen_tcp.close(socket)
      {:tcp_error, ^socket, _reason} ->
        :gen_tcp.close(socket)
    end
  end
end

defmodule Echo.Passive do
  def start(port \\ 6666) do
    opts = [:binary, active: false, packet: :line, reuseaddr: true]  # note: active: false
    {:ok, listen} = :gen_tcp.listen(port, opts)
    accept(listen)
  end

  def accept(listen) do
    {:ok, socket} = :gen_tcp.accept(listen)  # data delivered as messages in the mailbox of the
                                             # process that calls accept
    spawn(fn -> accept(listen) end)
    loop(socket)
  end

  def loop(socket) do
    case :gen_tcp.recv(socket, 0) do
      {:ok, data} ->
        :gen_tcp.send(socket, data)
        loop(socket)
      {:error, _reason} ->
        :gen_tcp.close(socket)
    end
  end
end

defmodule Echo.Hybrid do
  def start(port \\ 6666) do
    opts = [:binary, active: :once, packet: :line, reuseaddr: true]
    {:ok, listen} = :gen_tcp.listen(port, opts)
    accept(listen)
  end

  def accept(listen) do
    {:ok, socket} = :gen_tcp.accept(listen)  # data delivered as messages in the mailbox of the
                                             # process that calls accept (the controlling process)
    spawn(fn -> accept(listen) end)
    loop(socket)
  end

  defp loop(socket) do
    receive do
      {:tcp, ^socket, data} ->
        :inet.setopts(socket, active: :once)
        :gen_tcp.send(socket, data)
        loop(socket)
      {:tcp_closed, ^socket} ->
        :gen_tcp.close(socket)
      {:tcp_error, ^socket, _reason} ->
        :gen_tcp.close(socket)
    end
  end
end

defmodule Echo do
  use GenServer
  require Logger

  def start(port \\ 6666) do
    GenServer.start(__MODULE__, port)
  end

  @impl true
  def init(port) do
    opts = [:binary, active: true, packet: :line, reuseaddr: true]
    {:ok, listen} = :gen_tcp.listen(port, opts)
    send(self(), :accept)
    {:ok, listen}
  end

  @impl true
  def handle_info(:accept, listen) do
    {:ok, socket} = :gen_tcp.accept(listen)
    log(socket, "accepted connection")
    {:ok, pid} = Echo.Worker.start(socket)
    :gen_tcp.controlling_process(socket, pid)
    send(self(), :accept)
    {:noreply, listen}
  end

  defp log(socket, msg) do
    Logger.info("#{inspect self()}: #{msg} #{inspect socket}")
  end
end

defmodule Echo.Worker do
  use GenServer
  require Logger

  def start(socket) do
    GenServer.start(__MODULE__, socket)
  end

  @impl true
  def init(socket) do
    log(socket, "started worker")
    {:ok, socket}
  end

  @impl true
  def handle_info({:tcp, socket, data}, socket) do
    :inet.setopts(socket, active: :once)
    :gen_tcp.send(socket, data)
    {:noreply, socket}
  end

  @impl true
  def handle_info({:tcp_closed, socket}, socket) do
    :gen_tcp.close(socket)
    log(socket, "closed connection")
    {:stop, :normal, socket}
  end

  defp log(socket, msg) do
    Logger.info("#{inspect self()}: #{msg} #{inspect socket}")
  end
end

