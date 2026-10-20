-module(counter_worker).
-behaviour(gen_server).
-export([init/1, handle_call/3, handle_cast/2]).
-export([start_link/1, inc/1, value/0]).
-define(SERVER, ?MODULE).
-define(TABLE, counter_table).

start_link(N) ->
	gen_server:start_link({local, ?SERVER}, ?MODULE, N, []).

inc(Amt) ->
	gen_server:cast(?SERVER, {inc, Amt}).

value() ->
	gen_server:call(?SERVER, value).

init(N) ->
	case ets:lookup(?TABLE, value) of
		[] -> {ok, N};
		[{_, M} | _] -> {ok, M}
	end.

handle_call(value, _From, N) ->
	{reply, N, N}. % {reply, actual_reply, state}

handle_cast({inc, Amt}, N) ->
	{noreply, N + Amt}.

termintate(_Reason, N) ->
	ets:insert(?TABLE, {value, N}).
