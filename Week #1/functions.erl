-module(functions).
-export([head/1, second/1, same/2]). %% replace with -export() later, for God's sake!

head([H|_]) -> H.

second([_,S|_]) -> S.

same(X,X) ->
true;
same(_,_) ->
false.