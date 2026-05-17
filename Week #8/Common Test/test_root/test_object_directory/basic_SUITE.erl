-module(basic_SUITE).
-include_lib("common_test/include/ct.hrl").
-export([all/0]).
-export([test1/1, test2/1]).

all() -> [test1,test2].

test1(_Config) ->
    1 = 1.

test2(_Config) ->
    A = 0,
    1/A.

% cd("C:/repos/erlang_academy/Week #8/Common Test/test_root/test_object_directory").