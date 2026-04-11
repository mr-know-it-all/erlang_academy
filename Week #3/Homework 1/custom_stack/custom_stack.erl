-module(custom_stack).
-export([new/0, push/2, pop/1, peek/1, is_empty/1, size/1]).

new() ->
    {0, []}.

push({Size, Stack}, Element) ->
    {Size + 1, [Element | Stack]}.

pop({_, []}) ->
    {0, []};
pop({Size, [Top | Rest]}) ->
    {{Size - 1, Rest}, Top}.

peek({_, []}) ->
    {error, empty_stack};
peek({_, [Top | _]}) ->
    Top.

is_empty({0, []}) ->
    true;
is_empty({_, _}) ->
    false.

size({Size, _}) ->
    Size.

