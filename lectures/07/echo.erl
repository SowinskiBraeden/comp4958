-module(echo).
-export([start/1]).

start(Port) ->
	Opts = [binary, {active, once}, {packet, line}, {reuseaddr, true}],
	{ok, Listen} = gen_tcp:listen(Port, Opts),
	accept(Listen).

accept(Listen) ->
	{ok, Socket} = gen_tcp:accept(Listen),
	spawn(fun() -> accept(Listen) end),
	loop(Socket).

loop(Socket) ->
	receive
		{tcp, Socket, Data} ->
			inet:setopts(Socket, [{active, once}]),
			gen_tcp:send(Socket, Data),
			loop(Socket);
		{tcp_closed, Socket} ->
			gen_tcp:close(Socket)
	end.
