%% Declares the module name. This supervisor manages one specific pool.
-module(ppool_sup).

%% Exports the API and callback functions.
-export([start_link/3, init/1]).

%% Implements the supervisor behavior.
-behaviour(supervisor).

%% Starts the supervisor for a specific pool.
%% Name: The name of the pool.
%% Limit: Maximum number of concurrent workers allowed.
%% MFA: The {Module, Function, Args} used to start workers.
start_link(Name, Limit, MFA) ->
    %% Passes the pool details to the init/1 function.
    supervisor:start_link(?MODULE, {Name, Limit, MFA}).

%% Configures the pool's internal processes.
init({Name, Limit, MFA}) ->
    %% Very strict restart intensity: if it fails once in an hour, the whole pool fails.
    MaxRestart = 1,
    MaxTime = 3600,
    
    %% 'one_for_all' strategy: This pool currently only has one child (the server),
    %% but if we had more, a crash in one would restart all of them.
    {ok, {{one_for_all, MaxRestart, MaxTime},
          [
           %% Child ID: 'serv' (the pool's management server).
           {serv,
             %% Start Func: Calls ppool_serv:start_link.
             %% 'self()' passes the supervisor's PID to the server so it knows who its parent is.
             {ppool_serv, start_link, [Name, Limit, self(), MFA]},
             %% Restart: 'permanent' ensures the pool server is always restarted if it crashes.
             permanent,
             %% Shutdown: 5 seconds allowed for a clean exit.
             5000,
             %% Type: This process is a worker (it contains the logic, not other supervisors).
             worker,
             %% Modules: Used for hot code reloading.
             [ppool_serv]}
          ]}}.