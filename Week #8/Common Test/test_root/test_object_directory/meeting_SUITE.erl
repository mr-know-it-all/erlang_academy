-module(meeting_SUITE).
-include_lib("common_test/include/ct.hrl").
-export([all/0, groups/0, init_per_suite/1, end_per_suite/1, init_per_group/2, end_per_group/2]).
-export([carla/1, mark/1, dog/1, all_same_owner/1]).

all() -> [{group, session}].

groups() -> [{session,
              [],
              [{group, clients}, all_same_owner]},
             {clients,
              [parallel, {repeat, 10}],
              [carla, mark, dog]}].

%% Start the server ONCE for the entire suite run
init_per_suite(Config) ->
    catch meeting:stop(),
    timer:sleep(50),
    meeting:start(),
    Config.

%% Stop the server ONCE at the very end
end_per_suite(_Config) ->
    catch meeting:stop(),
    ok.

%% Leave these empty so repetitions don't constantly restart the server
init_per_group(_GroupName, Config) ->
    Config.

end_per_group(_GroupName, _Config) ->
    ok.

carla(_Config) ->
    meeting:book_room(women),
    timer:sleep(10),
    meeting:rent_projector(women),
    timer:sleep(10),
    meeting:use_chairs(women).

mark(_Config) ->
    meeting:rent_projector(men),
    timer:sleep(10),
    meeting:use_chairs(men),
    timer:sleep(10),
    meeting:book_room(men).

dog(_Config) ->
    meeting:rent_projector(animals),
    timer:sleep(10),
    meeting:use_chairs(animals),
    timer:sleep(10),
    meeting:book_room(animals).

all_same_owner(_Config) ->
    [{_,Owner}, {_, Owner}, {_, Owner}] = meeting:get_all_bookings().