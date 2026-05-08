%%% This is the "Front-End" or API module. It provides a clean, unified interface 
%%% so the user doesn't have to know which internal module (serv or supersup) to call.
-module(ppool).

%% Exporting the public API functions.
-export([start_link/0, stop/0, start_pool/3,
         run/2, sync_queue/2, async_queue/2, stop_pool/1]).

%% Starts the entire ppool application by calling the top-level supervisor.
start_link() ->
    ppool_supersup:start_link().

%% Shuts down the entire application and all its running pools.
stop() ->
    ppool_supersup:stop().

%% Creates a new load-balanced pool with a specific name, worker limit, and MFA.
%% MFA is the {Module, Function, Arguments} template for the workers.
start_pool(Name, Limit, {M,F,A}) ->
    ppool_supersup:start_pool(Name, Limit, {M,F,A}).

%% Stops and removes a specific pool by its name.
stop_pool(Name) ->
    ppool_supersup:stop_pool(Name).

%% Tries to run a task immediately. Returns 'noalloc' if the pool is full.
run(Name, Args) ->
    ppool_serv:run(Name, Args).

%% Queues a task asynchronously. If the pool is full, it waits in the queue 
%% without blocking the calling process.
async_queue(Name, Args) ->
    ppool_serv:async_queue(Name, Args).

%% Queues a task synchronously. If the pool is full, the calling process 
%% hangs (is blocked) until a worker slot becomes available.
sync_queue(Name, Args) ->
    ppool_serv:sync_queue(Name, Args).