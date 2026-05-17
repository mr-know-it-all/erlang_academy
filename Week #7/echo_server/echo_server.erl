-module(echo_server).
-export([start/1, acceptor/1, worker/1]).

%% 1. Start the server and create a 'Listen' socket
start(Port) ->
    {ok, LSock} = gen_tcp:listen(Port, [binary, {packet, 0}, {active, false}, {reuseaddr, true}]),
    io:format("Server listening on port ~p~n", [Port]),
    spawn(?MODULE, acceptor, [LSock]).

%% 2. Wait for a client connection
acceptor(LSock) ->
    {ok, Sock} = gen_tcp:accept(LSock),
    % Spawn a dedicated process for this specific client
    WorkerPid = spawn(?MODULE, worker, [Sock]),
    % Transfer socket ownership to the new worker process
    gen_tcp:controlling_process(Sock, WorkerPid),
    % Continue accepting other clients
    acceptor(LSock).

%% 3. Handle data in '{active, once}' mode
worker(Sock) ->
    % Enable 'once' mode to receive exactly one message
    inet:setopts(Sock, [{active, once}]),
    receive
        {tcp, Sock, Data} ->
            io:format("Received: ~p~n", [Data]),
            gen_tcp:send(Sock, Data), % Echo back
            worker(Sock);             % Loop and re-enable {active, once}
        {tcp_closed, Sock} ->
            io:format("Client disconnected~n");
        {tcp_error, Sock, Reason} ->
            io:format("Error: ~p~n", [Reason])
    end.