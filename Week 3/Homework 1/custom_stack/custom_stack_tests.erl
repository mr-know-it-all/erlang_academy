-module(custom_stack_tests).
-include_lib("eunit/include/eunit.hrl").

new_stack_test_() -> [
    ?_assertEqual({0, []}, custom_stack:new())
].  

push_test_() -> [
    ?_assertEqual({1, [1]}, custom_stack:push(custom_stack:new(), 1)),
    ?_assertEqual({2, [2, 1]}, custom_stack:push(custom_stack:push(custom_stack:new(), 1), 2))
].

pop_test_() -> [
    ?_assertEqual({{0, []}, 1}, custom_stack:pop(custom_stack:push(custom_stack:new(), 1)))
].

peek_test_() -> [
    ?_assertEqual(2, custom_stack:peek(custom_stack:push(custom_stack:new(), 2))),
    ?_assertEqual({error, empty_stack}, custom_stack:peek(custom_stack:new()))
].

is_empty_test_() -> [
    ?_assert(custom_stack:is_empty(custom_stack:new())),
    ?_assertNot(custom_stack:is_empty(custom_stack:push(custom_stack:new(), 1)))
].

% S0 = custom_stack:new(),
% S1 = custom_stack:push(S0, one),
% 1 = custom_stack:size(S1),
% S2 = custom_stack:push(S1, two),
% 2 = custom_stack:size(S2),
% {S3, two} = custom_stack:pop(S2),
% 1 = custom_stack:size(S3).