-module(m8ball_sup).
-behaviour(supervisor).
-export([start_link/0, init/1]).

start_link() ->
    supervisor:start_link({global,?MODULE}, ?MODULE, []).

init([]) ->
    {ok, {{one_for_one, 1, 10},
          [{m8ball,
            {m8ball_server, start_link, []},
            permanent,
            5000,
            worker,
            [m8ball_server]
          }]}}.


% +-------------------------------------------------------------+


% |                         m8ball_sup                          |
% |                     (Global Supervisor)                     |
% +-------------------------------------------------------------+


%                                |
%                                |  Restarts on Failure
%                                |  (Max 1 crash per 10s)

%                                |
%                                v
% +-------------------------------------------------------------+

% |                        m8ball_server                        |
% |                       (Worker Process)                      |
% +-------------------------------------------------------------+

%   * Start Link : m8ball_server:start_link/0
%   * Restart    : permanent (Always restarts)
%   * Shutdown   : 5000ms (Graceful termination timeout)