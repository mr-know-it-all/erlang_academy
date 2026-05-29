%%% The supervisor in charge of all the socket acceptors.
-module(sockserv_sup).
-behaviour(supervisor).

-export([start_link/0, start_socket/0]).
-export([init/1]).

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->
    Port = application:get_env(sockserv, port, 8080),
    %% Set active to false to prevent the supervisor from swallowing data
    {ok, ListenSocket} = gen_tcp:listen(Port, [{active, false}, 
                                              {packet, line}, 
                                              {reuseaddr, true}]),
    %% Use an asynchronous cast to empty listeners AFTER init completely returns
    gen_server:cast(self(), spawn_initial_listeners),
    {ok, {{simple_one_for_one, 60, 3600},
         [{socket,
          {sockserv_serv, start_link, [ListenSocket]},
          temporary, 1000, worker, [sockserv_serv]}
         ]}}.

start_socket() ->
    supervisor:start_child(?MODULE, []).

%% Start with 20 listeners so that many multiple connections can
%% be started at once, without serialization. In best circumstances,
%% a process would keep the count active at all times to insure nothing
%% bad happens over time when processes get killed too much.
empty_listeners() ->
    [start_socket() || _ <- lists:seq(1,20)],
    ok.