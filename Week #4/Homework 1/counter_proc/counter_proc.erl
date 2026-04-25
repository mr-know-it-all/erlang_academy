-module(counter_proc).
-export([start/0, start/1, stop/1, loop/1]).

%% Api Functions
start() ->
    start(0).
start(InitialValue)  when is_integer(InitialValue) ->
    spawn(fun() -> loop(InitialValue) end);
start(_) ->
    {error, badarg}.

stop(Pid) ->
    Pid ! {self(), stop},
    receive
        stopped -> ok
    after 5000 ->
        {error, timeout}
    end.

%% Server Loop
loop(State) ->
    receive
        {From, ping} ->
            From ! pong,
            loop(State);

        {From, {inc, N}} when is_integer(N) ->
            From ! ok,
            loop(State + N);

        {From, {inc, _}} ->
            From ! {error, badarg},
            loop(State);

        {From, get} ->
            From ! {ok, State},
            loop(State);

        {From, stop} ->
            From ! stopped,
            ok;

        {From, _} ->
            From ! {error, unsupported},
            loop(State)
    end.