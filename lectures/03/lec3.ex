# how to implement a generic server
# motivation for GenServer
defmodule GenericServer do
  ### Server Implementation ###

  # pass in a module 'm', since module names are just atoms
  # more generic, take in starting args and pass to modules
  # init function to do whatever is required beforehand
  def start(m, arg) do
    state = m.init(arg)
    spawn(fn -> loop(m, state) end)
  end

  defp loop(m, state) do
    receive do
      {:call, msg, from} ->
        {reply, new_state} = m.handle_call(msg, from, state)
        send(from, {self(), reply})
        loop(m, new_state)

      {:cast, msg} ->
        new_state = m.handle_cast(msg, state)
        loop(m, new_state)
    end
  end

  ### Client API ###
  def call(pid, msg, timeout \\ 5000) do
    send(pid, {:call, msg, self()})

    receive do
      # pin operator, reply must have same pid as call argument pid
      {^pid, x} -> x
    after
      timeout ->
        :timeout
    end
  end

  def cast(pid, msg) do
    send(pid, {:cast, msg})
  end
end

defmodule Counter do
  ### Server Implementation ###
  def start(file) do
    GenericServer.start(__MODULE__, file)
  end

  def init(file) do
    with {:ok, content} <- File.read(file),
         {n, _} <- Integer.parse(content) do
      n
    end
    if is_integer(val), do: val, else: 0
  end

  def handle_call(:value, _from, state) do
    # -> {reply, new_state} in GenericServer
    {state, state}
  end

  def handle_cast({:inc, amt}, state) do
    state + amt
  end

  ### Client API ###
  def value(pid) do
    GenericServer.call(pid, :value)
  end

  def inc(pid, amt \\ 1) do
    GenericServer.cast(pid, {:inc, amt})
  end
end
