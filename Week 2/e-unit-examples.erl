-module(filter_tests).

-include_lib("eunit/include/eunit.hrl").

empty_list_returned_as_is_test() ->
    ?assertEqual([], demo_recur:filter(fun(_) -> true end, [])).

empty_list_returned_when_all_elements_fail_test() ->
    ?assertEqual([], demo_recur:filter(fun(_) -> false end, [1, 2, 3])).

input_list_returned_when_all_elements_pass_test() ->
    ?assertEqual([1, 2, 3], demo_recur:filter(fun(_) -> true end, [1, 2, 3])).

input_list_filtered_like_lists_filter_test() ->
    Predicate = fun(X) -> X rem 2 == 0 end,
    InputList = [1, 2, 3],
    ?assertEqual(lists:filter(Predicate, InputList), demo_recur:filter(Predicate, InputList)).