-module(counter_proc_tests).
-include_lib("eunit/include/eunit.hrl").

counter_test_() ->
    {setup,
     fun setup/0,
     fun cleanup/1,
     fun(Pid) ->
         [
          ?_assertMatch(pong, counter_proc:ping(Pid)),
          ?_assertMatch({ok, 10}, counter_proc:get_value(Pid)),
          ?_assertMatch(ok, counter_proc:inc(Pid, 5)),
          ?_assertMatch({ok, 15}, counter_proc:get_value(Pid)),
          ?_assertMatch({error, badarg}, counter_proc:inc(Pid, not_an_int)),
          ?_assertMatch({ok, 15}, counter_proc:get_value(Pid))
         ]
     end}.

setup() ->
    {ok, Pid} = counter_proc:start(10),
    Pid.

cleanup(Pid) ->
    counter_proc:stop(Pid).

% eunit:test(counter_proc).