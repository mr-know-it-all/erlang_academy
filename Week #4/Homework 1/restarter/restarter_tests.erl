-module(restarter_tests).
-include_lib("eunit/include/eunit.hrl").

restarter_test_() ->
    {timeout, 10,
     fun() ->
         Pid = restarter:start_link({counter, loop, [0]}),
         ?assert(is_pid(Pid)),

         {Status, ChildPid} = restarter:status(Pid),
         ?assertEqual(ok, Status),
         ?assert(is_pid(ChildPid)),

         %% Waiting for the counter to crash and restart
         timer:sleep(2500),

         {Status2, Reason} = restarter:status(Pid),
         {Message, _} = Reason,
         ?assertEqual(restarting, Status2),
         ?assertEqual("Counter reached 4, intentional crash!", Message),

         timer:sleep(1000), 

         {Status3, NewChildPid} = restarter:status(Pid),
         ?assertEqual(ok, Status3),

         {Result, State} = restarter:stop(Pid),
         ?assertEqual(ok, Result),
         ?assertEqual(stopped, State)
     end}.