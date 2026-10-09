# register a process that can store key, value pairs
Registry.start_link(name: R, keys: :duplicate)

# register(register_name, key, value)
Register.register(R, "hello", "world")
Register.lookup(R, "hello")

# here we can associate a name, with a process ID
# can allow us to dynamically start any number of Workers
Registry.register(R, {Counter.Worker, "c1"})

f = fn (k, v) -> spawn(fn -> Registry.register(R, k, v); Process.sleep(30_000) end) end
pid = f.(:abc, 1)
Registry.keys(R, pid) # get all the keys for a PID -> [:abc]
Process.alive?(pid) # once dead i.e. returns -> false then:
Registry.keys(R, pid) # the process ID will be gone, -> [] not [:abc]


# Using our dynamic_counters implementation we have a counter server
# that is fault tolerant, i.e. if a worker dies, they will restart
DynamicSupervisor.start_child(Counter.DynamicSupervisor, {Counter.Worker, "c1"})
# -> {:ok, #PID<0.147.0>}
{_, pid} = v
# -> {:ok, #PID<0.147.0>}
Counter.Worker.inc("c1")
# -> :ok
Counter.Worker.inc("c1")
# -> :ok
Counter.Worker.value("c1")
# -> 2

# we can crash and see it restarts
Counter.Worker.inc("c1", "hello")
# -> :ok

# 10:04:25.932 [error] GenServer {Counter.Registry, {Counter.Worker, "c1"}} terminating
# ** (ArithmeticError) bad argument in arithmetic expression
	# :erlang.+(2, "hello")
	# (dynamic_counters 0.1.0) lib/dynamic_counters/worker.ex:37: Counter.Worker.handle_cast/2
	# (stdlib 6.2.2.5) gen_server.erl:2371: :gen_server.try_handle_cast/3
	# (stdlib 6.2.2.5) gen_server.erl:2433: :gen_server.handle_msg/6
	# (stdlib 6.2.2.5) proc_lib.erl:329: :proc_lib.init_p_do_apply/3
# Last message: {:"$gen_cast", {:inc, "hello"}}
# State: 2
Counter.Worker.value("c1")
# -> 0 has restarted without retaining state
Enum.each(1..100_000, fn n -> DynamicSupervisor.start_child(Counter.DynamicSupervisor, {Counter.Worker, "d#{n}"}) end )
# -> :ok
Enum.each(1..100_000, fn n -> Counter.Worker.inc("d#{n}", n) end)
# -> :ok
Enum.map(1..10, fn n -> Counter.Worker.value("d#{n}") end)
# -> [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]


### Erlang Term Store
t = :ets.new(T, [])
# you can insert tuples of any number of elements, but typically just a key, value pair
# by default you cannot have duplicate keys
:ets.insert(t, {:a, 1})
:ets.lookup(t, :a) # -> [a: 1] lookup only matches the first element of a tuple
:ets.insert(t, {"hello", 2, :abc})

:ets.tab2list(t) # -> [{a: 2}, {"hello, 2, :abc}]
:ets.insert(t, {"world", 3, :xyz})
:ets.match_object(t, {"hello", :_, :_}) # -> [{"hello", 2, :abc}]

:ets.new(T, [:named_table, :public]) # can also use a named table and not need to assign to something like t
:ets.insert(T, {:abc, 123})
:ets.lookup(T, :abc);

System.schedulers_online()
