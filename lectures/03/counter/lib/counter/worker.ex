defmodule Counter.Worker do
    use GenServer # use builtint Elixir Generic Server

    ### Client API ###
    def start(n \\ 0) do
        GenServer.start(__MODULE__, n)
    end

    def inc(pid, amt \\ 1) do
      GenServer.cast(pid, {:inc, amt})
    end

    def dec(pid, amt \\ 1) do
        GenServer.cast(pid, {:dec, amt})
    end

    def value(pid) do
      GenServer.call(pid, :value)
    end

    ### Server Impl ###
    @impl true       # annotation that signature agrees with callback
    def init(arg) do # arg comes from 2nd arg of GenServer.start
        {:ok, arg}
    end

    @impl true
    def handle_call(:value, _from, state) do
      {:reply, state, state} # {:reply, actual_reply, new_state}
    end

    @impl true
    def handle_cast({:inc, amt}, state) do
        {:noreply, state + amt} # {:noreply, new_state}
    end

    @impl true
    def handle_cast({:dec, amt}, state) do
        {:noreply, state - amt} # {:noreply, new_state}
    end
end
