-module(linkmon).
-compile([export_all]).

myproc() ->
    timer:sleep(5000),
    exit(reason).

chain(0) ->
    receive
        _ -> ok
    after 2000 ->
        exit("chain dies here")
    end;
chain(N) ->
    % io:format("Spawning chain with N = ~p~n", [N]),
    Pid = spawn(fun() -> chain(N-1) end),
    Link = link(Pid),
    io:format("Spawned process ~p with link ~p~n", [N, Link]),
    receive
        _ -> ok
    end.

start_critic() -> 
    spawn(?MODULE, critic, []).

judge(Pid, Band, Album) ->
    Pid ! { self(), { Band, Album } },
    receive 
        { Pid, Criticism } -> Criticism
    after 2000 -> 
        timeout
    end.

critic() -> 
    receive
        {From, {"Rage Against the Turing MAchine", "Unit Tetify"}} ->
            From ! {self(), "They are great!"};
        {From, {"System of a Downtime", "Memoize"}} ->
            From ! {self(), "They are not Johnny Cash, but they are good"};
        {From, "Johhny Cash", "The Token Ring of Fire"} -> 
            From ! {self(), "Simply incredible."};
        {From, {_Band, _Album}} ->
            From ! {self(), "They are terrible!"}
    end,
    critic().

% starts the restarter process
% which will monitor critic process
start_critic2() -> 
    spawn(?MODULE, restarter, []).

restarter() -> 
    % this will catch exit signals from critic process and restart it if it dies without good reason
    process_flag(trap_exit, true),
    % spawns a new process and links it to the current one
    % in order to receive exit signals from it
    Pid = spawn_link(?MODULE, critic2, []),
    % every time critic is restarted it will be registered with the current Pid
    register(critic, Pid),
    receive
        {'EXIT', Pid, normal} ->
            ok;
        {'EXIT', Pid, shutdown} ->
            ok;
        {'EXIT', Pid, _} ->
            % if critic process failed without good reason it will be restarted by reruning this function
            io:format("Restarting critic...~n"),
            restarter()
    end.

judge2(Band, Album) ->
    Ref = make_ref(),
    critic ! {self(), Ref, {Band, Album}},
    receive
        {Ref, Criticism} -> Criticism
    after 2000 ->
        io:format("The critic is not responding. Restarting...~n"),
        timeout
    end.

critic2() ->
    receive
        {From, Ref, {"Rage Against the Turing Machine", "Unit Testify"}} ->
            From ! {Ref, "They are great!"};
        {From, Ref, {"System of a Downtime", "Memoize"}} ->
            From ! {Ref, "They're not Johnny Crash but they're good."};
        {From, Ref, {"Johnny Crash", "The Token Ring of Fire"}} ->
            From ! {Ref, "Simply incredible."};
        {From, Ref, {_Band, _Album}} ->
            From ! {Ref, "They are terrible!"}
    end,
    critic2().


% 75> linkmon:start_critic2().
% <0.290.0>
% 76> linkmon:judge2("The Doors", "Light my Firewall").
% "They are terrible!"
% 77> exit(whereis(critic), kill).
% Restarting critic...
% true
% 78> linkmon:judge2("The Doors", "Light my Firewall").
% "They are terrible!"
% 79>

