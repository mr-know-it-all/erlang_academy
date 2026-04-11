-module(hhfuns).
-export([filter/2]).

filter(Pred, L) -> lists:reverse(filter(Pred, L,[])).
 
filter(_, [], Acc) -> Acc;
filter(Pred, [H|T], Acc) ->
case Pred(H) of
true  -> filter(Pred, T, [H|Acc]);
false -> filter(Pred, T, Acc)
end.