-module(counter_proc).
-behaviour(gen_server).

-export([start/0, start/1, stop/1, get_value/1, inc/2, ping/1]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2]).

start() -> start(0).

start(InitialValue) when is_integer(InitialValue) ->
    gen_server:start(?MODULE, InitialValue, []);
start(_) ->
    {error, badarg}.

stop(Pid) ->
    gen_server:stop(Pid).

ping(Pid) ->
    gen_server:call(Pid, ping).

inc(Pid, N) ->
    gen_server:call(Pid, {inc, N}).

get_value(Pid) ->
    gen_server:call(Pid, get).

init(InitialValue) ->
    {ok, InitialValue}.

handle_call(ping, _From, State) ->
    {reply, pong, State};
handle_call({inc, N}, _From, State) when is_integer(N) ->
    {reply, ok, State + N};
handle_call({inc, _}, _From, State) ->
    {reply, {error, badarg}, State};
handle_call(get, _From, State) ->
    {reply, {ok, State}, State};
handle_call(_Request, _From, State) ->
    {reply, {error, unsupported}, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

% cd("C:/repos/erlang_academy/Week #6/Homework/counter_proc").
% {ok, Pid} = counter_proc:start(10).
% counter_proc:get_value(Pid).
% counter_proc:ping(Pid).
% counter_proc:inc(Pid, "not an integer").
% counter_proc:inc(Pid, 2).
% counter_proc:get_value(Pid).
% counter_proc:stop(Pid).
