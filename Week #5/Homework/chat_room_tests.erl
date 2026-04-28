-module(chat_room_tests).
-include_lib("eunit/include/eunit.hrl").

chat_room_test_() ->
    {setup,
    % SETUP:
    fun() -> 
        % Question: when setting to larger value test not working even if that time is awaited
        {ok, Pid} = chat_room:start_link(test_room, #{cleanup_threshold => 0}), 
        Pid 
    end,
    % TEARDOWN
    fun(Pid) -> chat_room:stop(Pid) end,
    % TESTS
    fun(Pid) ->
        {inorder, [
            {"Initial room is empty",
             ?_assertMatch([], chat_room:members(Pid))},

            {"User can join",
             ?_assertEqual(ok, chat_room:join(Pid, <<"alice">>))},

            {"Duplicate join returns error",
             ?_assertEqual({error, already_joined}, chat_room:join(Pid, <<"alice">>))},

            {"Multiple members can exist",
             ?_test(begin
                 ok = chat_room:join(Pid, <<"bob">>),
                 Members = chat_room:members(Pid),
                 ?assertEqual(2, length(Members)),
                 ?assert(lists:member(<<"alice">>, Members)),
                 ?assert(lists:member(<<"bob">>, Members))
             end)},

            {"Members can send messages",
             ?_test(begin
                 chat_room:send_message(Pid, <<"alice">>, <<"Hi bob">>),
                 timer:sleep(50), 
                 History = chat_room:history(Pid),
                 ?assertEqual(1, length(History)),
                 [Msg] = History,
                 ?assertEqual(<<"alice">>, element(2, Msg)),
                 ?assertEqual(<<"Hi bob">>, element(4, Msg))
             end)},

            {"Non-members cannot send messages",
             ?_test(begin
                 chat_room:send_message(Pid, <<"intruder">>, <<"I'm not here">>),
                 timer:sleep(50),
                 ?assertEqual(1, length(chat_room:history(Pid)))
             end)},

            {"User can leave",
             ?_test(begin
                 ok = chat_room:leave(Pid, <<"alice">>),
                 ?assertNot(lists:member(<<"alice">>, chat_room:members(Pid))),
                 ?assertEqual({error, not_member}, chat_room:leave(Pid, <<"alice">>))
             end)},

            {"Cleanup tick removes inactive users",
             ?_test(begin
                 %% Bob is still in the room from the 'Multiple members' test
                 ?assert(lists:member(<<"bob">>, chat_room:members(Pid))),
                 
                 %% Manually trigger cleanup
                 Pid ! cleanup_tick,
                 timer:sleep(50),
                 
                 %% Bob should be gone because cleanup_threshold is 0
                 ?assertEqual([], chat_room:members(Pid))
             end)}
        ]}
     end}.