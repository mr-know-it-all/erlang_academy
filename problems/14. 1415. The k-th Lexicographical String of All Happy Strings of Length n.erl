join(Xs) -> list_to_atom(lists:concat(lists:map(fun atom_to_list/1, Xs))).

kth(_, []) -> '';
kth(0, [X|Xs]) -> join(X);
kth(K, [X|Xs]) -> kth(K - 1, Xs).

sort(Xs) -> lists:sort(Xs).

compute(_, Curr, Acc, 0) -> [Curr|Acc];

compute(a, Val, Acc, N) ->
    compute(b, [b|Val], Acc, N - 1) ++
    compute(c, [c|Val], Acc, N - 1);

compute(b, Val, Acc, N) ->
    compute(a, [a|Val], Acc, N - 1) ++
    compute(c, [c|Val], Acc, N - 1);

compute(c, Val, Acc, N) ->
    compute(b, [b|Val], Acc, N - 1) ++
    compute(a, [a|Val], Acc, N - 1);

compute(none, _, Acc, N) -> 
    compute(a, [a], Acc, N - 1) ++
    compute(b, [b], Acc, N - 1) ++
    compute(c, [c], Acc, N - 1).


-spec get_happy_string(N :: integer(), K :: integer()) -> unicode:unicode_binary().
get_happy_string(N, K) ->
  kth(K - 1, sort(compute(none, [], [], N))).
  