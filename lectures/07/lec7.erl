-module(lec7).
-export([fact/1, qsort/1, fizzbuzz/1, dedup/1]).

fact(N) when N =< 0 -> 1;
fact(N) -> N fact(N - 1).

qsort([]) -> [];
qsort([H | T]) ->
	qsort([X || X <- T, X =< H]) ++ [H] ++ qsort([X || X <- T, X > H]).

fizzbuzz(N) -> fizzbuzz(1, N);
fizzbuzz(I, N) when I > N -> ok;
fizzbuzz(I, N) ->
	% ~n is newline in erlang, not \n
	if
		I rem 15 == 0 -> io.format("fizzbuzz~n");
		I rem 5 == 0 -> io.format("buzz~n");
		I rem 3 == 0 -> io.format("fizz~n");
		true -> io.format("~p~n", [I])
	end,
	fizzbuzz(I + 1, N).

dedup([]) -> [];
dedup([X, X | R]) -> dedup([X|R]);
dedup([X|R]) -> [X | dedup(R)].

dedup2(L) ->
	case L of
		[] -> [];
		[X, X | R] -> dedup2([X|R]);
		[X | R] -> [X | dedup2(R)]
	end.

% compile
% c(lec7)
% lec7:fact(100)
% lec7:qsort([3,2,7,6,8])

F = fun(X) -> X * X end.
lists:map(F, [1,3,2]).
lists:map(fun string:length/1, ["hello", "goodbye"]).

% accessing maps

M = #{"bart" => 77, "homer" => 25}.
#{"homer" := X} = M.
X.
