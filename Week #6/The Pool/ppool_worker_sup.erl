%% Declares the module name, which must match the filename 'ppool_worker_sup.erl'.
-module(ppool_worker_sup).

%% Exports the functions start_link/1 and init/1 so they can be called from outside the module.
-export([start_link/1, init/1]).

%% Informs the compiler that this module implements the 'supervisor' behavior.
%% The compiler will warn you if required callback functions (like init/1) are missing.
-behaviour(supervisor).

%% This function is called to start the supervisor process.
%% It takes a 3-element tuple {Module, Function, Arguments} (MFA) as its argument.
start_link(MFA = {_,_,_}) ->
    %% Starts a supervisor process linked to the calling process.
    %% ?MODULE is a macro that expands to the current module name ('ppool_worker_sup').
    %% MFA is passed as the argument to the init/1 callback.
    supervisor:start_link(?MODULE, MFA).

%% This is the mandatory callback function called by the supervisor library to configure the process.
init({M,F,A}) ->
    %% If more than 5 restarts occur within 3600 seconds (1 hour), the supervisor terminates itself.
    MaxRestart = 5,
    MaxTime = 3600,

    %% Returns the supervisor configuration:
    %% 1. {simple_one_for_one, MaxRestart, MaxTime}: 
    %%    - 'simple_one_for_one' is used for dynamically adding many similar children. 
    %%    - All children are started from the same template.
    %% 2. The Child Specification list:
    {ok, {{simple_one_for_one, MaxRestart, MaxTime},
          [
           %% Child ID: internal name (ppool_worker)
           {ppool_worker, 
            %% Start Func: The {M, F, A} used to start the worker process.
            {M,F,A},
            %% Restart: 'temporary' means the supervisor never restarts the worker, 
            %% even if it crashes (ideal for pool workers managed by a separate process).
            temporary, 
            %% Shutdown: The time (5000ms) to wait for the child to stop before killing it.
            5000, 
            %% Type: Identifies the child as a 'worker' process (rather than another supervisor).
            worker, 
            %% Modules: A list of modules used by the child process (used during hot code upgrades).
            [M]}
          ]}}.