-module(counter_proc_tests).
-include_lib("eunit/include/eunit.hrl").

counter_proc_test() ->
    %start with bad argument
    ?assertEqual({error, badarg}, counter_proc:start("not an integer")),

    % start with no argument
    PidNoInitial = counter_proc:start(),
    PidNoInitial ! {self(), get},
    ?assertEqual({ok, 0}, receive {ok, Value} -> {ok, Value} end),

    Pid = counter_proc:start(10),

    %% ping
    Pid ! {self(), ping},
    % Question: What is the best approach to test these situations
    % where the process might not respond? Should we use a timeout in the receive block?
    ?assertEqual(pong, receive pong -> pong end),

    %% get
    Pid ! {self(), get},
    ?assertEqual({ok, 10}, receive {ok, Value} -> {ok, Value} end),

    %% inc with valid input
    Pid ! {self(), {inc, 5}},
    ?assertEqual(ok, receive ok -> ok end),
    Pid ! {self(), get},
    ?assertEqual({ok, 15}, receive {ok, Value} -> {ok, Value} end),

    %% inc with invalid input
    Pid ! {self(), {inc, "invalid"}},
    ?assertEqual({error, badarg}, receive {error, Reason} -> {error, Reason} end),
    Pid ! {self(), get},
    ?assertEqual({ok, 15}, receive {ok, Value} -> {ok, Value} end),

    %% unsupported message
    Pid ! {self(), unsupported_message},
    ?assertEqual({error, unsupported}, receive {error, Reason} -> {error, Reason} end),
    Pid ! {self(), get},
    ?assertEqual({ok, 15}, receive {ok, Value} -> {ok, Value} end),

    %% stop
    counter_proc:stop(Pid).

