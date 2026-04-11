-module(list_utils_prop_tests).
-include_lib("eqc/include/eqc.hrl").
-compile(export_all).

% TODO: think of function that will return for some ints bad result to validate test

prop_filter_match() ->
    ?FORALL({List, Pred}, {list(int()), function1(bool())},
        list_utils:filter(Pred, List) == lists:filter(Pred, List)).


% 15>  eqc:quickcheck(list_utils_prop_tests:prop_filter_match()).
% Starting Quviq QuickCheck Mini version 2.02.0
%    (compiled for R25 at {{2022,9,29},{14,39,40}})
%    (Warning: You are using R28)
% .....................................................................................................
% OK, passed 101 tests
% true
% 16>