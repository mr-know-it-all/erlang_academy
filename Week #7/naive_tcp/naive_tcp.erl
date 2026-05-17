-module(naive_tcp).
-compile(export_all).

%% Entry point: Sets up the environment and the first listener
start_server(Port) ->
    Pid = spawn_link(fun() ->
        %% Open the port for listening
        %% [binary]: Data arrives as raw bytes
        %% {active, false}: We start in "passive" mode (server must pull data)
        %% {packet, line}: Erlang buffers data until a newline (\n) is received
        {ok, Listen} = gen_tcp:listen(Port, [binary, {active, false}, {packet, line}]),
        
        %% Spawn the first acceptor process to wait for the first client
        spawn(fun() -> acceptor(Listen) end),
        
        %% Keep this "Manager" process alive indefinitely
        timer:sleep(infinity)
    end),
    {ok, Pid}.

%% The "Conveyor Belt": Accepts a connection and spawns its own replacement
acceptor(ListenSocket) ->
    io:format("Acceptor called!", []),
    %% Process blocks here until a TCP handshake is completed
    {ok, Socket} = gen_tcp:accept(ListenSocket),
    
    %% Immediately spawn a NEW acceptor to wait for the next client.
    %% This prevents the server from being "blocked" while talking to Client A.
    spawn(fun() -> acceptor(ListenSocket) end),
    
    %% This specific process now becomes the dedicated handler for THIS client
    handle(Socket).

%% The "Loop": Manages data exchange for a single socket
handle(Socket) ->
    io:format("Handle called!", []),
    %% Switch to {active, once}: 
    %% The next TCP packet will be sent to our mailbox as an Erlang message.
    %% This provides automatic flow control (backpressure).
    inet:setopts(Socket, [{active, once}]),
    
    receive
        %% If the binary starts with "quit", close and terminate process
        {tcp, Socket, <<"quit", _/binary>>} ->
            gen_tcp:close(Socket);
            
        %% Pattern match any other message
        {tcp, Socket, Msg} ->
            %% Append "-test" to the binary data
            NewMsg = <<Msg/binary, "-test">>,
            gen_tcp:send(Socket, NewMsg),
            
            %% Recursive call to handle the next message (Tail Call Optimized)
            handle(Socket)
    end.


% $ telnet localhost 8091
% Trying 127.0.0.1...
% Connected to localhost.
% Escape character is '^]'.
% hey there
% hey there
% that's what I asked
% that's what I asked
% stop repeating >:(
% stop repeating >:(
% quit doing that!
% Connection closed by foreign host.


% [ Start Server ]

%          |
%          V
%   [ Listen Socket ] <--------------------------+
%          |                                     |
%          V                                     |
%   [ Acceptor Proc ] --(Waits for Client)       | (Recursion)

%          |                                     |
%   (Client Connects)                            |

%          |                                     |
%          +---- [ Spawn New Acceptor ] ---------+
%          |
%          V
%   [ Handler Proc ] --(Receive/Send Loop)
% 


    %   +--------------+

    %    |   WAITING    | <-----------+
    %    | (active once)|             |
    %    +--------------+             |

    %           |                     |
    %   (TCP Message Arrives)         | (Recursive Call)

    %           |                     |
    %           V                     |
    %    +--------------+             |

    %    |  PROCESSING  |-------------+
    %    | (Append Msg) |
    %    +--------------+

    %           |
    %     (If "quit")
    %           |
    %           V
    %    +--------------+

    %    |    CLOSE     |
    %    |  (Terminate) |
    %    +--------------+