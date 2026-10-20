-module(counter_supervisor).
-behaviour(supervisor).
-export([start_link/0, init/1]).
-define(TABLE, counter_table).

start_link() ->
	ets:new(?TABLE, [named_table, public]),
	supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init(_) ->
	Flags = #{strategy => one_for_one},
	ChildSpecs = [#{id => worker1,
					staart => {counter_worker, start_link, [0]}}],
	{ok, {Flags, ChildSpecs}}.
