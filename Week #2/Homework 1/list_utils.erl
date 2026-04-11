-module(list_utils).
-export([filter/2, map/2, fold/3]).

% % ----------------------------------
% % Simple recursive -----------------
% % ----------------------------------
% % ----------------------------------

% filter(_Predicate, []) ->
%     [];
% filter(Predicate, [H|T]) ->
%     case Predicate(H) of
%         true -> [H | filter(Predicate, T)];
%         false -> filter(Predicate, T)
%     end.

% map(_Function, []) ->
%     [];
% map(Function, [H|T]) ->
%     [Function(H) | map(Function, T)].

% fold(_Function, Acc, []) ->
%     Acc;
% fold(Function, Acc, [H|T]) ->
%     fold(Function, Function(H, Acc), T).



% ----------------------------------
% Tail Call optimized --------------
% ----------------------------------
% ----------------------------------

% ----------------------------------
% Filter ---------------------------
% ----------------------------------

filter(Predicate, List) ->
    filter_tail(Predicate, List, []).

filter_tail(_Predicate, [], Acc) ->
    lists:reverse(Acc);
% check property testing
% filter_tail(Predicate, [0|T], Acc) ->
%     filter_tail(Predicate, T, Acc);
filter_tail(Predicate, [H|T], Acc) ->
    case Predicate(H) of
        true -> filter_tail(Predicate, T, [H | Acc]);
        false -> filter_tail(Predicate, T, Acc)
    end.

% ----------------------------------
% Map ------------------------------
% ----------------------------------

map(Function, List) ->
    map_tail(Function, List, []).

map_tail(_Function, [], Acc) ->
    lists:reverse(Acc); 
map_tail(Function, [H|T], Acc) ->
    MappedItem = Function(H),
    map_tail(Function, T, [MappedItem | Acc]).

% ----------------------------------
% Fold -----------------------------
% ----------------------------------

fold(Function, Acc, List) ->
    fold_tail(Function, Acc, List).

fold_tail(_Function, Acc, []) ->
    Acc;
fold_tail(Function, Acc, [H|T]) ->
    UpdatedAcc = Function(H, Acc),
    fold_tail(Function, UpdatedAcc, T).


% % ----------------------------------
% % List comprehension ---------------
% % ----------------------------------
% % ----------------------------------

% filter(Predicate, List) ->
%     [H || H <- List, Predicate(H)].

% map(Function, List) ->
%     [Function(H) || H <- List].

