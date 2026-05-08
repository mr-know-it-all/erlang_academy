%% Define the module name 'ppool_nagger'.
-module(ppool_nagger).

%% Specify that this module implements the gen_server (generic server) behavior.
-behaviour(gen_server).

%% Export public API functions so they can be called from other modules.
-export([start_link/4, stop/1]).

%% Export the standard gen_server callback functions required by the behavior.
-export([init/1, handle_call/3, handle_cast/2,
         handle_info/2, code_change/3, terminate/2]).

%% API: Starts a nagger process linked to the calling process.
%% Takes the Task to nag about, Delay between nags, Max number of times, and the recipient SendTo.
start_link(Task, Delay, Max, SendTo) ->
    gen_server:start_link(?MODULE, {Task, Delay, Max, SendTo} , []).

%% API: Stops the nagger process synchronously.
stop(Pid) ->
    gen_server:call(Pid, stop).

%% Initializes the server state with the provided task details.
%% Returns the state and a timeout value (Delay) to trigger the first nag.
init({Task, Delay, Max, SendTo}) ->
    {ok, {Task, Delay, Max, SendTo}, Delay}.

%%% OTP Callbacks

%% Handles the synchronous 'stop' call. Returns a stop instruction to the gen_server.
handle_call(stop, _From, State) ->
    {stop, normal, ok, State};
%% Catch-all for any other synchronous calls; does nothing and keeps the state.
handle_call(_Msg, _From, State) ->
    {noreply, State}.

%% Handles asynchronous messages. Currently ignores all cast messages.
handle_cast(_Msg, State) ->
    {noreply, State}.

%% Handles the 'timeout' message triggered by the Delay interval.
handle_info(timeout, {Task, Delay, Max, SendTo}) ->
    %% Send the task reminder to the destination process.
    SendTo ! {self(), Task},
    
    %% Logic to determine if the nagger should continue or stop.
    if Max =:= infinity ->
        %% If set to infinity, keep going and reset the timeout.
        {noreply, {Task, Delay, Max, SendTo}, Delay};
       Max =< 1 ->
        %% If this was the last nag, stop the process normally.
        {stop, normal, {Task, Delay, 0, SendTo}};
       Max > 1  ->
        %% Decrease the counter and reset the timeout for the next nag.
        {noreply, {Task, Delay, Max-1, SendTo}, Delay}
    end.

%% Standard callback for hot code upgrades; simply keeps the current state.
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%% Standard cleanup callback called when the process is about to exit.
terminate(_Reason, _State) -> ok.