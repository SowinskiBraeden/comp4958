defmodule Counter.Worker do
    use GenServer # use builtint Elixir Generic Server

    ### Client API ###
    def inc(amt \\ 1) do
      GenServer.cast(__MODULE__, {:inc, amt})
    end

    def dec(amt \\ 1) do
        GenServer.cast(__MODULE__, {:dec, amt})
    end

    def value() do
      GenServer.call(__MODULE__, :value)
    end

    ### Server Impl ###
    def start(n \\ 0) do
        # use module name as name for registered server
        # now inc, dec, and value dont need pid, and can use __MODULE__
        GenServer.start(__MODULE__, n, name: __MODULE__)
    end

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
