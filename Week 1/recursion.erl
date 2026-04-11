-module(recursion).
-export([zip/2, tail_zip/2]).

zip([],_) -> [];
zip(_,[]) -> [];
zip([X|Xs],[Y|Ys]) -> [{X,Y}|zip(Xs,Ys)].

tail_zip(Xs, Ys) -> tail_zip(Xs, Ys, []).

tail_zip([],_,Acc) -> Acc;
tail_zip(_,[],Acc) -> Acc;
tail_zip([X|Xs],[Y|Ys],Acc) -> tail_zip(Xs,Ys,[{X,Y}|Acc]).