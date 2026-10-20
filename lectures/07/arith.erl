-module(arith).
-export([start/0, square/2, sqrt/2]).

start() ->
	{ok, _Pid} = spawn(fun loop/0).

square(Pid, N) ->
	Pid ! {square, self(), N},
	receive
		{Pid, Reply} -> Reply
	end.

sqrt(Pid, N) ->
	Pid ! {sqrt, self(), N},
	receive
		{Pid, Reply} -> Reply
	end.

loop() ->
	receive
		{square, From, N} ->
			From ! {self(), N * N};
		{sqrt, From, N} when N < 0 ->
			From ! {self(), error};
		{sqrt, From, N} ->
			From ! {self(), math:sqrt(N)}
	end,
	loop().
