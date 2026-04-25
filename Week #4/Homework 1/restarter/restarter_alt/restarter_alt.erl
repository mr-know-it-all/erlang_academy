-module(restarter_alt).
-export([start_link/1, status/1, stop/1, init/1]).

start_link({M, F, A} = MFA) ->
    spawn_link(?MODULE, init, [MFA]).

status(Pid) ->
    Pid ! {get_status, self()},
    ok.

stop(Pid) ->
    %% We monitor the restarter so we can wait for it to actually die
    MRef = erlang:monitor(process, Pid),
    Pid ! stop,
    receive
        {'DOWN', MRef, process, Pid, _} -> ok
    after 2000 -> 
        %% Hard kill if it refuses to stop
        exit(Pid, kill),
        ok
    end.

init(MFA) ->
    process_flag(trap_exit, true),
    ChildPid = do_spawn(MFA),
    loop(MFA, {ok, ChildPid}).

loop(MFA, State) ->
    receive
        stop ->
            io:format("Stopping restarter. Terminating child if alive...~n", []),
            case State of
                {ok, ChildPid} -> 
                    unlink(ChildPid),
                    exit(ChildPid, kill);
                _ -> ok
            end,
            exit(normal); %% Terminate restarter

        {get_status, From} ->
            From ! {status, State},
            loop(MFA, State);

        {'EXIT', _Pid, Reason} ->
            io:format("Child died. Restarting in 1s...~n"),
            erlang:send_after(2000, self(), do_restart),
            loop(MFA, {restarting, Reason});

        do_restart ->
            io:format("Restarting child with MFA: ~p~n", [MFA]),
            NewPid = do_spawn(MFA),
            loop(MFA, {ok, NewPid})
    end.

do_spawn({M, F, A}) ->
    spawn_link(M, F, A).