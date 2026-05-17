%%% ==========================================================================
%%% MODULE: sockserv_serv
%%% 
%%% DESCRIPTION: 
%%% A gen_server that bridges a TCP raw socket (client) to the game engine.
%%%
%%% --------------------------------------------------------------------------
%%% 1. SYSTEM ARCHITECTURE (Process Supervision)
%%%
%%%      [sockserv_sup] (Supervisor)
%%%             |
%%%             | (1) Spawns
%%%             v
%%%      [sockserv_serv] (Process A) <--- (2) Waits for connection
%%%             |
%%%             | (3) On Connection:
%%%             |     - Calls sockserv_sup:start_socket() 
%%%             |       (Spawns Process B to listen for next client)
%%%             |     - Owns the socket and starts interaction
%%%             v
%%%      [TCP Client / Telnet]
%%%
%%% --------------------------------------------------------------------------
%%% 2. STATE TRANSITION DIAGRAM (The 'next' field logic)
%%%
%%%    [State: undefined] --(gen_tcp:accept)--> [State: name]
%%%                                               |
%%%          (User enters name) <-----------------+
%%%             |
%%%             V
%%%    [State: {stats, Roll}] <---(roll_stats)----+
%%%             |                                 |
%%%             +-- (User enters "n") ------------+
%%%             |
%%%             +-- (User enters "y") --> [State: playing]
%%%                                           |
%%%    (Game Events Forwarded) <--------------+
%%%
%%% --------------------------------------------------------------------------
%%% 3. SOCKET FLOW CONTROL (active, once)
%%%
%%%    [Client] ----(Data)----> [Erlang Socket Buffer] --(Send Msg)--> [Process]
%%%                                                                      |
%%%    [Client] <---(Response)-- [Socket Closed to Input] <---(Process logic)
%%%                                       |
%%%    [Client] ----(Wait)----> [inet:setopts({active, once})] --(Re-open)-->
%%% ==========================================================================

-module(sockserv_serv).
-behaviour(gen_server).

%% Internal state record
-record(state, {name,    % player's name string
                next,    % atom or tuple representing current state
                socket}). % the connected TCP socket

%% API
-export([start_link/1]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         code_change/3, terminate/2]).

%% Macros
-define(SOCK(Msg), {tcp, _Port, Msg}). % Helper for matching TCP data
-define(TIME, 800).                    % Speed of game ticks
-define(EXP, 50).                      % Difficulty constant

%% ==========================================================================
%% API / Initialization
%% ==========================================================================

start_link(Socket) ->
    gen_server:start_link(?MODULE, Socket, []).

init(Socket) ->
    %% Seed random for stat rolling
    <<A:32, B:32, C:32>> = crypto:rand_bytes(12),
    random:seed({A,B,C}),
    %% Cast to self to perform blocking 'accept' outside of init
    gen_server:cast(self(), accept),
    {ok, #state{socket=Socket}}.

%% ==========================================================================
%% Handle Cast (Internal Logic Events)
%% ==========================================================================

%% Phase 1: Wait for a user to connect to the listening socket
handle_cast(accept, S = #state{socket=ListenSocket}) ->
    {ok, AcceptSocket} = gen_tcp:accept(ListenSocket),
    %% Boot up a new listener process to handle the next person
    sockserv_sup:start_socket(),
    send(AcceptSocket, "What's your character's name?", []),
    {noreply, S#state{socket=AcceptSocket, next=name}};

%% Phase 2: Roll random RPG stats and present them
handle_cast(roll_stats, S = #state{socket=Socket}) ->
    Roll = pq_stats:initial_roll(),
    send(Socket,
         "Stats for your character:~n"
         "  Charisma: ~B~n"
         "  Constitution: ~B~n"
         "  Dexterity: ~B~n"
         "  Intelligence: ~B~n"
         "  Strength: ~B~n"
         "  Wisdom: ~B~n~n"
         "Do you agree to these? y/n~n",
         [Points || {_Name, Points} <- lists:sort(Roll)]),
    {noreply, S#state{next={stats, Roll}}};

%% Phase 3: Finalize character and start the engine
handle_cast(stats_accepted, S = #state{name=Name, next={stats, Stats}}) ->
    processquest:start_player(Name, [{stats,Stats},{time,?TIME},
                                     {lvlexp, ?EXP}]),
    %% Hook this process up to the engine's event stream
    processquest:subscribe(Name, sockserv_pq_events, self()),
    {noreply, S#state{next=playing}};

%% Phase 4: Forward engine events to the player's screen
handle_cast(Event, S = #state{name=N, socket=Sock}) when element(1, Event) =:= N ->
    [case E of
       {wait, Time} -> timer:sleep(Time);
       IoList -> send(Sock, IoList, [])
     end || E <- sockserv_trans:to_str(Event)], 
    {noreply, S}.

%% ==========================================================================
%% Handle Info (External Messages / Socket Input)
%% ==========================================================================

handle_call(_E, _From, State) -> {noreply, State}.

%% Handle "quit" command
handle_info(?SOCK("quit"++_), S) ->
    processquest:stop_player(S#state.name),
    gen_tcp:close(S#state.socket),
    {stop, normal, S};

%% Handle input during NAME phase
handle_info(?SOCK(Str), S = #state{next=name}) ->
    Name = line(Str),
    gen_server:cast(self(), roll_stats),
    {noreply, S#state{name=Name, next=stats}};

%% Handle input during STATS approval phase
handle_info(?SOCK(Str), S = #state{socket=Socket, next={stats, _}}) ->
    case line(Str) of
        "y" -> gen_server:cast(self(), stats_accepted);
        "n" -> gen_server:cast(self(), roll_stats);
        _ -> send(Socket, "Answer with y (yes) or n (no)", [])
    end,
    {noreply, S};

%% Fallback for game input or errors
handle_info(?SOCK(E), S = #state{socket=Socket}) ->
    send(Socket, "Unexpected input: ~p~n", [E]),
    {noreply, S};

handle_info({tcp_closed, _Socket}, S)   -> {stop, normal, S};
handle_info({tcp_error, _Socket, _}, S) -> {stop, normal, S};
handle_info(E, S) ->
    io:format("unexpected: ~p~n", [E]),
    {noreply, S}.

%% ==========================================================================
%% Helpers & Cleanup
%% ==========================================================================

code_change(_OldVsn, State, _Extra) -> {ok, State}.

terminate(normal, _State) -> ok;
terminate(_Reason, _State) -> io:format("terminate reason: ~p~n", [_Reason]).

%% Send formatted string to socket and re-enable active mode for 1 message
send(Socket, Str, Args) ->
    ok = gen_tcp:send(Socket, io_lib:format(Str++"~n", Args)),
    ok = inet:setopts(Socket, [{active, once}]),
    ok.

%% Strip whitespace and newlines from raw socket strings
line(Str) ->
    hd(string:tokens(Str, "\r\n ")).