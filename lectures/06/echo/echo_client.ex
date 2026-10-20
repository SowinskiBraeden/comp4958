defmodule Echo.Client do
  def connect(host, port \\ 6666) do
    opts = [active: false, packet: :line]
    {:ok, socket} = :gen_tcp.connect(host, port, opts)
    loop(socket)
  end

  defp loop(socket) do
    case IO.gets("> ") do
      :eof ->
        :gen_tcp.close(socket)
      line -> 
        :gen_tcp.send(socket, line)
        case :gen_tcp.recv(socket, 0) do
          {:ok, data} -> 
            IO.write(data) 
            loop(socket)
          {:error, _} ->
            :gen_tcp.close(socket)
        end
    end
  end
end

with [host, port | _] <- System.argv(),
     {port, _} <- Integer.parse(port)
do
  Echo.Client.connect(String.to_atom(host), port)
else
  _ -> Echo.Client.connect(:"127.0.0.1", 6666)
end
