-module(counter).
-export([loop/1]).

%% loop/1 - Simple counter that logs with timestamp at regular intervals
loop(State) ->
    {H, M, S} = erlang:time(),
    io:format("counter [~2..0w:~2..0w:~2..0w]: state=~p~n", [H, M, S, State]),
    if State >= 3 ->
        io:format("counter: Crashing at state=~p!~n", [State]),
        erlang:error("Counter reached 3, intentional crash!");
    true ->
        timer:sleep(1000),
        loop(State + 1)
    end.
