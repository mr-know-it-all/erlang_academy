% Notes:
% - I needed to export init/2 to start in the shell and be able to call status/1 and stop/1)
% - I did not check if child is active
% - Used a simple process for the child
% - The child processs automatically crashes after 3 seconds
% (we can test the restarter functionality without having to manually kill the child process)
% - A restart interval is simulated by sending a message to the loop process after a delay: `send_after`
% (we could also wait for a "initialized" message from the new Child process started)
% 
%
% Example usage:
% cd("C:/repos/erlang_academy/Week #4/Homework 1/restarter").
% Pid = restarter:start_link({counter, loop, [0]}).
% restarter:status(Pid).
% restarter:stop(Pid).

-module(restarter).
-export([start_link/1, status/1, stop/1, init/2]).

start_link(MFA) -> 
    %% Spawns the restarter process and links it to the caller
    %% So I can use it in the shell
    %% we can just run init(self(), MFA)
    %% but I want to run :status and :stop from the shell
    spawn_link(?MODULE, init, [self(), MFA]).

status(Pid) -> 
    io:format("Requesting status from restarter, self ~p~n", [self()]),
    %$ Pid is the loop
    %% self() is the caller of status/1
    Pid ! {get_status, self()},
    % receive will wait for the reply from the loop and return it to the caller of status/1
    % Question: without receive here the message will go to shell (self() caller process)?
    receive Reply -> Reply end.

stop(Pid) -> 
    %% Pid is the loop
    %% self() is the caller of stop/1
    Pid ! { stop, self()},
    % receive will wait for the reply from the loop and return it to the caller of stop/1
    receive Reply -> Reply end.

init(Parent, MFA) ->
    ChildPid = spawn_child(MFA),
    %% in the shell, Pid will be the loop process, and ChildPid will be the counter process
    %% Pid = restarter:start_link({counter, loop, [0]}).
    loop(MFA, {ok, ChildPid}, Parent).

spawn_child({M, F, A}) ->
    %% This also returns a ref, spawn only returns a pid
    {Pid, Ref} = spawn_monitor(M, F, A),
    Pid.

loop(MFA, State, Parent) ->
    receive
        {'DOWN', _, process, ChildPid, Reason} ->
            io:format("[RESTART schedule]: Child died with reason: ~p. Scheduling restart...~n", [Reason]),
            %% self() is here the loop process
            erlang:send_after(1000, self(), {restart, Reason}),
            % Parent ! {child_down, ChildPid, Reason},
            loop(MFA, {restarting, Reason}, Parent);
        {restart, Reason} ->
            io:format("[RESTART exec]: Restarting child due to: ~p~n", [Reason]),
            NewPid = spawn_child(MFA),
            % Parent ! {restarted, NewPid},
            loop(MFA, {ok, NewPid}, Parent);
        {get_status, From} ->
            {Status, ChildPid} = State,
            io:format("[STATUS]: Status requested. ChildPid: ~p~n", [ChildPid]),
            From ! {Status, ChildPid},
            loop(MFA, State, Parent);
        {stop, From} ->
            {Status, ChildPid} = State,
            io:format("[STOP]: Stopping restarter. Terminating child...~n", []),
            case Status of
                ok -> 
                    erlang:demonitor(erlang:monitor(process, ChildPid), [flush]),
                    exit(ChildPid, kill);
                _ -> ok
            end,
            From ! {ok, stopped},
            ok
    end.
