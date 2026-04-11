-module(list_utils_tests).
-include_lib("eunit/include/eunit.hrl").
% -export([run_all_tests/0]).

% run_all_tests() ->
%     filter_tests(),
%     map_tests(),
%     fold_tests().

% ----------------------------------
% Filter ---------------------------
% ----------------------------------

% filter_tests() ->
%     empty_list_returned_as_is_filter_test(),
%     empty_list_returned_when_all_elements_fail_test(),
%     input_list_returned_when_all_elements_pass_test(),
%     input_list_filtered_like_lists_filter_test().

empty_list_returned_as_is_filter_test() ->
    ?assertEqual([], list_utils:filter(fun(_) -> true end, [])).

empty_list_returned_when_all_elements_fail_test() ->
    ?assertEqual([], list_utils:filter(fun(_) -> false end, [1, 2, 3])).

input_list_returned_when_all_elements_pass_test() ->
    ?assertEqual([1, 2, 3], list_utils:filter(fun(_) -> true end, [1, 2, 3])).

input_list_filtered_like_lists_filter_test() ->
    Predicate = fun(X) -> X rem 2 == 0 end,
    InputList = [1, 2, 3],
    ?assertEqual(lists:filter(Predicate, InputList), list_utils:filter(Predicate, InputList)).


% ----------------------------------
% Map ------------------------------
% ----------------------------------

% map_tests() ->
%     empty_list_returned_as_is_map_test(),
%     input_list_mapped_like_lists_map_test().

empty_list_returned_as_is_map_test() ->
    ?assertEqual([], list_utils:map(fun(X) -> X * 2 end, [])).

input_list_mapped_like_lists_map_test() ->
    Function = fun(X) -> X * 2 end,
    InputList = [1, 2, 3],
    ?assertEqual(lists:map(Function, InputList), list_utils:map(Function, InputList)).

% ----------------------------------
% Fold -----------------------------
% ----------------------------------

% fold_tests() ->
%     empty_list_returns_acc_test(),
%     input_list_folded_like_lists_foldl_test().

empty_list_returns_acc_test() ->
    Function = fun(X, Acc) -> X + Acc end,
    Acc = 0,
    ?assertEqual(Acc, list_utils:fold(Function, Acc, [])).

input_list_folded_like_lists_foldl_test() ->
    Function = fun(X, Acc) -> X + Acc end,
    Acc = 0,
    InputList = [1, 2, 3],
    ?assertEqual(lists:foldl(Function, Acc, InputList), list_utils:fold(Function, Acc, InputList)).

% to execute tests in the shell:
% eunit:test(list_utils).