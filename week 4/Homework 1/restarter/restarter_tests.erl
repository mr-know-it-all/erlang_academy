-module(restarter_tests).
-include_lib("eunit/include/eunit.hrl").

restarter_test() ->
    Pid = restarter:start_link({counter, loop, [0]}),
    ?assert(is_pid(Pid)),

    {Status, ChildPid} = restarter:status(Pid),
    ?assertEqual(ok, Status),
    ?assert(is_pid(ChildPid)),

    %% This is not a great way to test this,
    %% but we can wait for the counter to crash and restart
    timer:sleep(4000), %% Wait for the counter to crash and restart

    {Status2, Reason} = restarter:status(Pid),
    {Message, _} = Reason,
    ?assertEqual(restarting, Status2),
    ?assertEqual("Counter reached 3, intentional crash!", Message),

    {Status3, State} = restarter:stop(Pid),
    ?assertEqual(ok, Status3),
    ?assertEqual(stopped, State).
