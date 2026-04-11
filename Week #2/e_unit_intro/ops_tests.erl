-module(ops_tests).
-include_lib("eunit/include/eunit.hrl").

add_test() ->
    4 = ops:add(2,2).

new_add_test() ->
    ?assertEqual(4, ops:add(2,2)),
    ?assertEqual(3, ops:add(1,2)),
    ?assert(is_number(ops:add(1,2))),
    ?assertEqual(3, ops:add(1,1)),
    ?assertError(badarith, 1/0).

add_test_() ->
    [test_them_types(),
     test_them_values(),
     ?_assertError(badarith, 1/0)].

test_them_types() ->
    ?_assert(is_number(ops:add(1,2))).

test_them_values() ->
    [?_assertEqual(4, ops:add(2,2)),
     ?_assertEqual(3, ops:add(1,2)),
     ?_assertEqual(3, ops:add(1,1))].


% eunit:test({generator, fun ops_tests:add_test_/0}).
% eunit:test(ops).
% 
% From /Learn You Some Erlang For Great Good!/:
% {module, Mod} runs all tests in Mod
% {dir, Path} runs all the tests for the modules found in Path
% {file, Path} runs all the tests found in a single compiled module
% {generator, Fun} runs a single generator function as a test, as seen above
% {application, AppName} runs all the tests for all the modules mentioned in AppName's .app file.

% [ PHASE 1: GENERATION ]
%    Your Function (ending in _test_())

%    |
%    |-- Executes normal Erlang logic (loops, lists, etc.)
%    |-- DOES NOT run the tests yet
%    V
% [ PHASE 2: THE DATA STRUCTURE ]
%    Returns a "Test Set" (The Recipe)
%    [
%       {"Test 1", ?_assert(X == Y)},   <-- A "fun" (test object)
%       {setup, Start, Stop, [          <-- A "fixture" wrapper
%           ?_assertEqual(A, B)
%       ]}
%    ]
%    V
% [ PHASE 3: EXECUTION ]
%    EUnit Runner Unpacks the Data

%    |
%    |-- 1. Runs Setup (if defined)
%    |-- 2. Executes each 'fun' individually
%    |-- 3. Runs Cleanup (if defined)
%    V
% [ PHASE 4: REPORTING ]
%    Displays Success/Failure Results