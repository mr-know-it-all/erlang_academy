Write an Erlang module that starts a process which maintains a counter as a state:
* Name: counter_proc. Exports: start/0, start/1 (initial value), stop/1 (Pid).
* The process communicates via messages; no global state.
* Accepted messages (from any process):
    - ping -> reply pong to the sender.
    - {inc, N} where N is integer (allow negative) -> update state State + N, reply ok.
    - get -> reply {ok, State} to the sender.
    - stop → reply stopped then terminate gracefully.
    - Unexpected messages -> ignore and reply {error, unsupported}.
* Must be tail-recursive; keep state in a loop argument.
* Add input validation: if {inc, N} where N is not integer -> reply {error, badarg} (no state change).

