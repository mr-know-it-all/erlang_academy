-module(multiproc).
-compile([export_all]).

sleep(T) ->
    receive
    after T -> ok
    end.

flush() ->
    receive
        _ -> flush()
    after 0 ->
        ok
    end.

important() ->
    receive
        {Priority, Message} when Priority > 10 ->
            io:format("Received important message: ~p~n", [Message]),
            [Message | important()]
    after 0 ->
        normal()
    end.

normal() ->
    receive
        {_, Message} ->
            io:format("Received normal message: ~p~n", [Message]),
            [Message | normal()]
    after 0 ->
        []
    end.

%% optimized in R14A
optimized(Pid) ->
    Ref = make_ref(),
    Pid ! {self(), Ref, hello},
    receive
        {Pid, Ref, Msg} ->
            io:format("~p~n", [Msg])
    end.



% 1> c(multiproc).
% {ok,multiproc}
% send messages to shell process with different priorities
% 2> self() ! {15, high}, self() ! {7, low}, self() ! {1, low}, self() ! {17, high}.      
% {17,high}
% 
% this will consume the messages in the shell process mailbox,
% and print the messages in order of priority
% 3> multiproc:important().
% [high,high,low,low]