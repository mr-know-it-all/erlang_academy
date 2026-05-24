-module(m8ball_server).
-behaviour(gen_server).
-export([start_link/0, stop/0, ask/1]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         code_change/3, terminate/2]).

%%%%%%%%%%%%%%%%%
%%% INTERFACE %%%
%%%%%%%%%%%%%%%%%
start_link() ->
    gen_server:start_link({global, ?MODULE}, ?MODULE, [], []).

stop() ->
    gen_server:call({global, ?MODULE}, stop).

ask(_Question) -> 
    gen_server:call({global, ?MODULE}, question).

%%%%%%%%%%%%%%%%%
%%% CALLBACKS %%%
%%%%%%%%%%%%%%%%%
init([]) ->
    _ = crypto:rand_seed(),
    {ok, []}.

handle_call(question, _From, State) ->
    {ok, Answers} = application:get_env(m8ball, answers),
    Answer = element(rand:uniform(tuple_size(Answers)), Answers),
    {reply, Answer, State};
handle_call(stop, _From, State) ->
    {stop, normal, ok, State};
handle_call(_Call, _From, State) ->
    {reply, {error, unknown_call}, State}.

handle_cast(_Cast, State) ->
    {noreply, State}.

handle_info(_Info, State) ->
    {noreply, State}.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

terminate(_Reason, _State) ->
    ok.

% +---------------------------------------------------------------------------------------+

% |                                     Client Process                                    |
% +---------------------------------------------------------------------------------------+

%           |                                                                   |
%           |  m8ball:ask(Question)                                             |  m8ball_server:stop()
%           |  (Triggers synchronous gen_server:call)                           |  (Triggers sync call)
%           v                                                                   v
% =========================================================================================
%                                    [ GLOBAL REGISTRY ]                                   
%                        Routes messages to {global, m8ball_server}                        
% =========================================================================================

%           |                                                                   |
%           |  {call, From, question}                                           |  {call, From, stop}
%           v                                                                   v
% +---------------------------------------------------------------------------------------+

% |                                  m8ball_server Process                                |
% +---------------------------------------------------------------------------------------+

% |  [ init/1 ]       -> Seeds random number generator with crypto:rand_seed/0.           |
% |                                                                                       |
% |  [ handle_call ]  -> question: Fetches 'answers' tuple from application env.          |
% |                                Selects random item using rand:uniform/1.              |
% |                                Returns chosen answer binary to client.                |
% |                   -> stop:     Returns 'ok' to client and triggers stop sequence.     |
% |                                                                                       |
% |  [ terminate/2 ]  -> Runs cleanup logic and exits cleanly with reason: 'normal'.      |
% +---------------------------------------------------------------------------------------+