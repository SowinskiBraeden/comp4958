# Lecture 06 notes: raw sockets, then splitting a client/server across nodes
# This file is not meant to be compiled/run as a whole - paste lines into
# iex (or a shell, where noted) one at a time.


### ---------------------------------------------------------------------- ###
### Part 1: echo/ - plain TCP, no distributed Elixir involved yet
### ---------------------------------------------------------------------- ###

# load the module definitions into an iex session (run from lectures/06/echo/)
# iex echo.ex

# Echo.Active / Echo.Passive / Echo.Hybrid all block the calling process
# forever inside accept/loop, so start them in a spawned process if you
# want your iex shell back:
spawn(fn -> Echo.Active.start(6666) end)
spawn(fn -> Echo.Passive.start(6667) end)
spawn(fn -> Echo.Hybrid.start(6668) end)

# the GenServer version returns immediately because init/1 just schedules
# :accept via send(self(), :accept) and returns - no spawn needed
Echo.start(6666)
# -> {:ok, #PID<...>}

# quick manual client, no Elixir needed - good for sanity-checking a server
# nc localhost 6666
# (type a line, press enter, see it echoed back; Ctrl-D or Ctrl-C to quit)

# or use the provided Elixir client (run from a second terminal):
# elixir echo_client.ex 127.0.0.1 6666
# (defaults to 127.0.0.1:6666 if no args given)

# or the Java client (compiles/runs independently - proves the server
# doesn't care what language/process connects, it's just bytes on a socket)
# cd ../java && javac EchoClient.java && java EchoClient


### ---------------------------------------------------------------------- ###
### Part 2: distributed Elixir basics - the mechanism the counter/ examples
### rely on instead of hand-rolled sockets
### ---------------------------------------------------------------------- ###

# Start two connected BEAM nodes (same machine is fine for testing).
# --sname gives each node a short name; both MUST share a cookie or they
# refuse to connect to each other.

# terminal 1 (this will become the "server" node):
# iex --sname server --cookie lecture06

# terminal 2 (this will become the "client" node):
# iex --sname client --cookie lecture06

# from either node, connect them:
Node.connect(:"server@your-hostname")
# -> true
# find the exact name to use with: Node.self() (run that on the server node)

Node.list()          # -> [:"client@your-hostname"] (from the server's side)
Node.self()           # -> the current node's own full name

# :global is what replaces Registry here - Registry is local-to-a-node only,
# :global registers names cluster-wide once nodes are connected
:global.registered_names()        # -> [] until something registers
:global.whereis_name(Counter.Worker)   # -> PID or :undefined


### ---------------------------------------------------------------------- ###
### Part 3: counter/static - one globally-registered counter
### ---------------------------------------------------------------------- ###

# -- server node --
# cd counter/static/server
# mix deps.get        # first time only
# iex --sname server --cookie lecture06 -S mix
# this boots Counter.Application, which starts Counter.Store (file-backed,
# "counter.db") and Counter.Worker (registered as {:global, Counter.Worker})

Counter.Worker.value()    # works locally on the server node too
Counter.Worker.inc(5)

# -- client node --
# cd counter/static/client   (NOT a mix project - just loose .ex files)
# iex --sname client --cookie lecture06
Node.connect(:"server@your-hostname")
c "worker.ex"              # compiles/loads Counter.Worker (the thin stub)

# these now run against the REAL process living on the server node -
# no socket code written by us, distributed Erlang routes the GenServer
# call/cast over the network
Counter.Worker.inc()
Counter.Worker.value()
# -> whatever the server node's Counter.Worker currently holds

# don't call Counter.Worker.start_link/1 from the client - the server's
# Application already started (and globally registered) the one that
# matters; starting another just races/duplicates the name


### ---------------------------------------------------------------------- ###
### Part 4: counter/dynamic - many named counters, started on demand,
### reachable from a remote node
### ---------------------------------------------------------------------- ###

# -- server node --
# cd counter/dynamic/server
# mix deps.get
# iex --sname server --cookie lecture06 -S mix
# boots: Registry (local, unused for cross-node lookup), an ETS table for
# crash-durable state, and Counter.DynamicSupervisor registered as
# {:global, Counter.DynamicSupervisor}

# -- client node --
# cd counter/dynamic/client
# iex --sname client --cookie lecture06
Node.connect(:"server@your-hostname")
c "dynamic_supervisor.ex"
c "worker.ex"

# ask the REMOTE supervisor (on the server node) to spawn a new worker -
# the child process is started under the server's supervision tree, not
# the client's
Counter.DynamicSupervisor.start_worker("c1")
# -> {:ok, #PID<...>}   (a server-node PID)

Counter.Worker.inc("c1")
Counter.Worker.inc("c1", 5)
Counter.Worker.value("c1")
# -> 6

# start as many independent counters as you like, all living on the
# server node, all addressable from the client by name:
Enum.each(1..5, fn n -> Counter.DynamicSupervisor.start_worker("c#{n}") end)
Enum.each(1..5, fn n -> Counter.Worker.inc("c#{n}", n) end)
Enum.map(1..5, fn n -> Counter.Worker.value("c#{n}") end)
# -> [1, 2, 3, 4, 5]

# kill a worker on the server node and watch it come back with its value
# intact (DynamicSupervisor restarts it, ETS on the server supplies the
# last known value in init/1):
# on the SERVER node:
Process.exit(:global.whereis_name("c1"), :kill)
# back on the CLIENT node:
Counter.Worker.value("c1")
# -> still 1 (reloaded from the server's ETS table in init/1, same pattern
# as lecture 05's local DynamicSupervisor/Registry/ETS combo - just now the
# "local" side is a different machine)


### ---------------------------------------------------------------------- ###
### Misc / troubleshooting
### ---------------------------------------------------------------------- ###

# cookie mismatch or wrong hostname are the two most common reasons
# Node.connect/1 silently returns false - check `iex --sname` output for
# the exact full node name, and make sure both nodes used the same --cookie

# run a mix app's tests / compile without a full iex session:
# mix test
# mix compile
# mix run --no-halt      # boots the Application and just hangs there running
