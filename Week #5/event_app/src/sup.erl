-module(sup).
-export([start/2, init/1, loop/1]).

start(Mod,Args) ->
    io:format("[start] Starting supervisor for ~p with args ~p~n", [Mod, Args]),
    spawn(?MODULE, init, [{Mod, Args}]).

% start_link(Mod,Args) ->
%     io:format("[start_link] Starting supervisor for ~p with args ~p~n", [Mod, Args]),
%     spawn_link(?MODULE, init, [{Mod, Args}]).

init({Mod,Args}) ->
    io:format("[init] Supervisor starting child process ~p with args ~p~n", [Mod, Args]),
    process_flag(trap_exit, true),
    loop({Mod,start_link,Args}).

loop({M,F,A}) ->
    io:format("[loop] Supervisor starting child process ~p with args ~p~n", [M, A]),
    Pid = apply(M,F,A),
    receive
        {'EXIT', _From, shutdown} ->
            io:format("[loop] Supervisor received shutdown signal, shutting down...~n"),
            exit(shutdown); % will kill the child too
        {'EXIT', Pid, Reason} ->
            io:format("Process ~p exited for reason ~p~n",[Pid,Reason]),
            loop({M,F,A})
    end.