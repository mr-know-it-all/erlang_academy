# Chat Room Server

Implement a chat room server as a gen_server.

The server represents one chat room and keeps all its state inside the gen_server process. The room should support joining and leaving members and posting messages.

```erlang
-module(chat_room).

%% API
-export([
    start_link/1,
    join/2,
    leave/2,
    send_message/3,
    history/1,
    members/1,
    stop/1
]).

%% API

-spec start_link(RoomName :: atom() | binary() | list()) -> {ok, Pid :: pid()} | {error, Reason :: any()}.
%% Starts a new chat room server linked to the caller. `RoomName` is the room identifier.
%% It can be an atom, a binary, or a list, depending on your chosen design,
%% but you should document what type you support.
%%
%% This function should initialize the gen_server state and return the server pid in the usual OTP style.
%%
%% Expected behaviour:
%%   * creates a new room with no members
%%   * creates empty message history
%%   * stores the room name in the state
start_link(RoomName) ->
    noimp.

-spec join(Server :: pid(), UserId :: binary()) -> ok | {error, Reason :: any()}.
%% Adds a user to the room.
%% Server is the gen_server pid.
%% UserId identifies a user.
%%
%% This should be implemented as a synchronous request.
%% Expected behavior:
%%   * if the user is not in the room, add them and return ok
%%   * if the user is already in the room, return an error such as {error, already_joined}
join(Server, UserId) ->
    noimp.

-spec leave(Server :: pid(), UserId :: binary()) -> ok | {error, Reason :: any()}.
%% Removes a user from the room.
%%
%% This should be implemented as a synchronous request.
%% Expected behavior:
%%   * if the user is in the room, remove them and return ok
%%   * if the user is not in the room, return an error such as {error, not_member}
leave(Server, UserId) ->
    noimp.

-spec send_message(Server :: pid(), UserId :: binary(), Text :: binary()) -> ok.
%% Posts a message into the room on behalf of UserId.
%%
%% This should be implemented as an asynchronous request.
%% Expected behavior:
%%    * if UserId is a current room member, append the message to the room history
%%    * if UserId is not a room member, ignore the message silently
%%
%% Message format
%% Choose a message format and keep it consistent.
%% For example, each stored room message may include:
%%    * sender
%%    * text
%%    * timestamp or sequence number
%% A simple example could be: %{sender_id => UserId, sent_at => Timestamp, text => Text}
%%
%% For timestamps, you can use erlang:system_time()
send_message(Server, UserId, Text) ->
    noimp.

-spec history(Server :: pid()) -> [Msg :: any()].
%% Returns the current message history for the room.
%%
%% This should be implemented as a synchronous request.
%% Expected behavior:
%%    * returns all stored messages in the order they were posted
history(Server) ->
    noimp.

-spec members(Server :: pid()) -> [UserId :: binary()].
%% Returns the current list or set of room members.
%%
%% This should be implemented as a synchronous request.
%% Expected behavior:
%%    * returns the current members
%%    * ordering is up to you
members(Server) ->
    noimp.

-spec stop(Server :: pid()) -> ok.
%% Stops the room server gracefully.
stop(Server) ->
    noimp.
```

## Expected semantics

### Membership rules
* A user must join the room before posting messages.
* A user cannot join twice.
* A user who is not a member cannot leave successfully.

### History rules

Option 1:
* unlimited history

Option 2:
* bounded history
* maximum 20 messages
* keep the newest 20
* drop the oldest one

### Error handling

Prefer simple and explicit results such as:
```erlang
ok
{error, already_joined}
{error, not_member}
```
## Stretch goals

These are optional and should not be required for everyone.

* internal inactivity cleanup - track last activity time per member and periodically remove inactive users using handle_info/2.
* duplicate suppression - prevent consecutive duplicate messages from the same user.
homework_chat_room_server.md