-module(conuter).
-behaviour(gen_server).
-export([init/1, handle_cast/2, handle_call/3]).
-export([start/1, value/1, inc/1, inc/2]).

start(N) ->
	gen_server.start(?MODULE, N, []).

inc(Pid) -> inc(Pid, 1).
inc(Pid, Amt) ->
	gen_server:cast(Pid, {inc, Amt}).

value(Pid) ->
	gen_server:call(Pid, value).

init(N) ->
	{ok, N}.

handle_call(value, _From, N) ->
	{reply, N, N}. % {reply, actual_reply, state}

handle_cast({inc, Amt}, N) ->
	{noreply, N + Amt}.
