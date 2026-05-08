%% Declares the module name; this acts as the "grand supervisor" for the entire application.
-module(ppool_supersup).

%% Implements the supervisor behavior.
-behaviour(supervisor).

%% API for starting/stopping the application and managing individual resource pools.
-export([start_link/0, stop/0, start_pool/3, stop_pool/1]).

%% The mandatory callback for the supervisor behavior.
-export([init/1]).

%% Starts the top-level supervisor and registers it locally under the name 'ppool'.
start_link() ->
    supervisor:start_link({local, ppool}, ?MODULE, []).

%% A helper function to shut down the pool application.
%% It finds the PID of the 'ppool' process and forces it to exit.
stop() ->
    case whereis(ppool) of
        P when is_pid(P) ->
            exit(P, kill); %% Sends a 'kill' signal (non-catchable) for a brutal shutdown.
        _ -> ok
    end.

%% Initializes the supervisor with no initial children ([]) and a 'one_for_one' strategy.
%% 'one_for_one' means if one pool supervisor dies, only that one is restarted.
init([]) ->
    MaxRestart = 6,
    MaxTime = 3600,
    {ok, {{one_for_one, MaxRestart, MaxTime}, []}}.

%% Dynamically adds a new pool to the system.
%% It creates a ChildSpec for a 'ppool_sup' (the supervisor for a specific pool).
start_pool(Name, Limit, MFA) ->
    ChildSpec = {Name,
                 {ppool_sup, start_link, [Name, Limit, MFA]},
                  permanent, %% If a pool supervisor crashes, it should be restarted.
                  10500,     %% Wait time for shutdown.
                  supervisor, %% Informs the system this child is also a supervisor.
                  [ppool_sup]},
    %% Tells the main 'ppool' supervisor to start this new child.
    supervisor:start_child(ppool, ChildSpec).

%% Removes a pool from the system.
stop_pool(Name) ->
    %% First, stop the process associated with the pool name.
    supervisor:terminate_child(ppool, Name),
    %% Second, remove the child specification from the supervisor's list.
    supervisor:delete_child(ppool, Name).