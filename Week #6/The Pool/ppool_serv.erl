%% The engine of the pool; manages the worker limit, queuing, and monitoring.
-module(ppool_serv).
-behaviour(gen_server).

%% API for starting the server and managing tasks.
-export([start/4, start_link/4, run/2, sync_queue/2, async_queue/2, stop/1]).
%% Gen_server callbacks.
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         code_change/3, terminate/2]).

%% Macro defining the child specification for the worker supervisor.
%% This tells the parent supervisor how to start 'ppool_worker_sup'.
-define(SPEC(MFA),
        {worker_sup,
         {ppool_worker_sup, start_link, [MFA]},
          temporary,
          10000,
          supervisor,
          [ppool_worker_sup]}).

%% State record to keep track of:
%% limit: current capacity, sup: worker supervisor PID, 
%% refs: active worker monitors, queue: waiting tasks.
-record(state, {limit=0,
                sup,
                refs,
                queue=queue:new()}).

%% --- API FUNCTIONS ---

%% Starts the server without a link to the caller.
start(Name, Limit, Sup, MFA) when is_atom(Name), is_integer(Limit) ->
    gen_server:start({local, Name}, ?MODULE, {Limit, MFA, Sup}, []).

%% Starts the server linked to the caller (usually called by ppool_sup).
start_link(Name, Limit, Sup, MFA) when is_atom(Name), is_integer(Limit) ->
    gen_server:start_link({local, Name}, ?MODULE, {Limit, MFA, Sup}, []).

%% Runs a task immediately; returns 'noalloc' if the pool is full.
run(Name, Args) ->
    gen_server:call(Name, {run, Args}).

%% Runs a task or blocks the caller (sync) until a slot is available.
sync_queue(Name, Args) ->
    gen_server:call(Name, {sync, Args}, infinity).

%% Adds a task to the queue and returns 'ok' immediately (non-blocking).
async_queue(Name, Args) ->
    gen_server:cast(Name, {async, Args}).

%% Shuts down the pool server.
stop(Name) ->
    gen_server:call(Name, stop).

%% --- CALLBACKS ---

init({Limit, MFA, Sup}) ->
    %% Trick: Send a message to ourselves to start the worker supervisor.
    %% This avoids a deadlock because the supervisor is currently waiting for init to return.
    self() ! {start_worker_supervisor, Sup, MFA},
    {ok, #state{limit=Limit, refs=gb_sets:empty()}}.

%% Handle 'run': Start worker if limit > 0, otherwise reject.
handle_call({run, Args}, _From, S = #state{limit=N, sup=Sup, refs=R}) when N > 0 ->
    {ok, Pid} = supervisor:start_child(Sup, Args),
    Ref = erlang:monitor(process, Pid),
    {reply, {ok,Pid}, S#state{limit=N-1, refs=gb_sets:add(Ref,R)}};
handle_call({run, _Args}, _From, S=#state{limit=N}) when N =< 0 ->
    {reply, noalloc, S};

%% Handle 'sync': Start worker if limit > 0, otherwise store 'From' in queue to block caller.
handle_call({sync, Args}, _From, S = #state{limit=N, sup=Sup, refs=R}) when N > 0 ->
    {ok, Pid} = supervisor:start_child(Sup, Args),
    Ref = erlang:monitor(process, Pid),
    {reply, {ok,Pid}, S#state{limit=N-1, refs=gb_sets:add(Ref,R)}};
handle_call({sync, Args},  From, S = #state{queue=Q}) ->
    {noreply, S#state{queue=queue:in({From, Args}, Q)}};

handle_call(stop, _From, State) ->
    {stop, normal, ok, State}.

%% Handle 'async': Start worker if limit > 0, otherwise just queue the Args.
handle_cast({async, Args}, S=#state{limit=N, sup=Sup, refs=R}) when N > 0 ->
    {ok, Pid} = supervisor:start_child(Sup, Args),
    Ref = erlang:monitor(process, Pid),
    {noreply, S#state{limit=N-1, refs=gb_sets:add(Ref,R)}};
handle_cast({async, Args}, S=#state{limit=N, queue=Q}) when N =< 0 ->
    {noreply, S#state{queue=queue:in(Args,Q)}}.

%% Triggered when a worker process finishes or crashes.
handle_info({'DOWN', Ref, process, _Pid, _}, S = #state{refs=Refs}) ->
    case gb_sets:is_element(Ref, Refs) of
        true -> handle_down_worker(Ref, S);
        false -> {noreply, S}
    end;
%% Triggered by the message sent in init/1 to start the sub-supervisor.
handle_info({start_worker_supervisor, Sup, MFA}, S = #state{}) ->
    {ok, Pid} = supervisor:start_child(Sup, ?SPEC(MFA)),
    link(Pid),
    {noreply, S#state{sup=Pid}}.

%% Boilerplate for code updates and termination.
code_change(_OldVsn, State, _Extra) -> {ok, State}.
terminate(_Reason, _State) -> ok.

%% Logic to process the queue when a worker slot opens up.
handle_down_worker(Ref, S = #state{limit=L, sup=Sup, refs=Refs}) ->
    case queue:out(S#state.queue) of
        %% A synchronous caller was waiting; start worker and reply to them.
        {{value, {From, Args}}, Q} ->
            {ok, Pid} = supervisor:start_child(Sup, Args),
            NewRef = erlang:monitor(process, Pid),
            NewRefs = gb_sets:insert(NewRef, gb_sets:delete(Ref,Refs)),
            gen_server:reply(From, {ok, Pid}),
            {noreply, S#state{refs=NewRefs, queue=Q}};
        %% An asynchronous task was waiting; start worker.
        {{value, Args}, Q} ->
            {ok, Pid} = supervisor:start_child(Sup, Args),
            NewRef = erlang:monitor(process, Pid),
            NewRefs = gb_sets:insert(NewRef, gb_sets:delete(Ref,Refs)),
            {noreply, S#state{refs=NewRefs, queue=Q}};
        %% Queue is empty; just increment the available limit.
        {empty, _} ->
            {noreply, S#state{limit=L+1, refs=gb_sets:delete(Ref,Refs)}}
    end.