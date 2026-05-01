-module(chat_room).
-behaviour(gen_server).
-export([
    start_link/1,
    start_link/2, %% New export for testing
    init/1,
    handle_call/3,
    handle_cast/2,
    handle_info/2,
    join/2,
    leave/2,
    send_message/3,
    history/1,
    members/1,
    stop/1
]).

-record(state, {
    name :: atom() | binary() | list(),
    members :: [binary()],
    last_activity = #{} :: map(),
    history :: [map()],
    cleanup_threshold = 60 :: integer() %% Added cleanup_threshold to state
}).

-record(message, {
    sender_id :: binary(),
    sent_at :: integer(),
    text :: binary()
}).

%% API

start_link(RoomName) ->
    Options = #{},
    start_link(RoomName, Options).

start_link(RoomName, Options) ->
    gen_server:start_link(?MODULE, [RoomName, Options], []).

-spec init(Args :: list()) -> {ok, State :: #state{}}.
init([RoomName, Options]) ->
    Threshold = maps:get(cleanup_threshold, Options, 60),
    io:format("Initializing chat room ~p with cleanup_threshold ~ps~n", [RoomName, Threshold]),
    erlang:send_after(60000, self(), cleanup_tick),
    {ok, #state{
        name = RoomName, 
        members = [], 
        last_activity = #{}, 
        history = [],
        cleanup_threshold = Threshold
    }}.

join(Server, UserId) -> gen_server:call(Server, {join, UserId}).
leave(Server, UserId) -> gen_server:call(Server, {leave, UserId}).
send_message(Server, UserId, Text) -> gen_server:cast(Server, {send_message, UserId, Text}).
history(Server) -> gen_server:call(Server, history).
members(Server) -> gen_server:call(Server, members).
stop(Server) -> gen_server:call(Server, stop).

% CALLBACKS

handle_call({join, UserId}, _From, State) ->
    case lists:member(UserId, State#state.members) of
        true -> {reply, {error, already_joined}, State};
        false ->
            NewMembers = [UserId | State#state.members],
            NewActivity = maps:put(UserId, erlang:system_time(second), State#state.last_activity),
            {reply, ok, State#state{members = NewMembers, last_activity = NewActivity}}
    end;

handle_call({leave, UserId}, _From, State) ->
    case lists:member(UserId, State#state.members) of
        false -> {reply, {error, not_member}, State};
        true -> 
            NewMembers = lists:delete(UserId, State#state.members),
            NewActivity = maps:remove(UserId, State#state.last_activity),
            {reply, ok, State#state{members = NewMembers, last_activity = NewActivity}}
    end;

handle_call(history, _From, State) -> {reply, State#state.history, State};
handle_call(members, _From, State) -> {reply, State#state.members, State};
handle_call(stop, _From, State) -> {stop, normal, ok, State}.

handle_cast({send_message, UserId, Text}, State) ->
    case lists:member(UserId, State#state.members) of
        false -> {noreply, State};
        true ->
            Timestamp = erlang:system_time(second),
            Msg = #message{sender_id= UserId, sent_at = Timestamp, text = Text},
            NewHistory = State#state.history ++ [Msg],
            NewActivity = maps:put(UserId, Timestamp, State#state.last_activity),
            {noreply, State#state{history = NewHistory, last_activity = NewActivity}}
    end.

%% CATCH ALL
handle_info(cleanup_tick, State) ->
    Now = erlang:system_time(second),
    Threshold = State#state.cleanup_threshold, 
    
    NewActivity = maps:filter(
        fun(_UserId, LastSeen) -> (Now - LastSeen) < Threshold end,
        State#state.last_activity
    ),
    NewMembers = maps:keys(NewActivity),

    Removed = State#state.members -- NewMembers,
    case Removed of
        [] -> ok;
        _  -> io:format("Cleaning up inactive users: ~p~n", [Removed])
    end,
    
    erlang:send_after(60000, self(), cleanup_tick),
    {noreply, State#state{members = NewMembers, last_activity = NewActivity}};

handle_info(_Info, State) ->
    {noreply, State}.

% To start the server:
% cd("C:/repos/erlang_academy/Week #5/Homework").
% {ok, Pid} = chat_room:start_link("my_room").
% To join the room:
% chat_room:join(Pid, <<"user1">>).
% To send a message:
% chat_room:send_message(Pid, <<"user1">>, <<"Hello, world!">>).
% To get the message history:
% chat_room:history(Pid).
% To get the members:
% chat_room:members(Pid).
% To stop the server:   
% chat_room:stop(Pid).  