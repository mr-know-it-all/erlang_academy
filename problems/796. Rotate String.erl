% Given two strings s and goal, return true if and only if s can become goal after some number of shifts on s.

% A shift on s consists of moving the leftmost character of s to the rightmost position.

% For example, if s = "abcde", then it will be "bcdea" after one shift.
 

% Example 1:

% Input: s = "abcde", goal = "cdeab"
% Output: true
% Example 2:

% Input: s = "abcde", goal = "abced"
% Output: false
 

% Constraints:

% 1 <= s.length, goal.length <= 100
% s and goal consist of lowercase English letters.

% SOLUTION 1:

-spec rotate_string(S :: unicode:unicode_binary(), Goal :: unicode:unicode_binary()) -> boolean().
rotate_string(S, Goal) ->
    A = binary_to_list(S),
    B = binary_to_list(Goal),
    Len = length(A),
    compute(A, B, Len).

compute(_A, _B, 0) -> false;
compute(B, B, _Len) -> true;
compute([H|T], Goal, Len) ->
    compute(T ++ [H], Goal, Len - 1).


% SOLUTION 2:

-spec rotate_string(S :: unicode:unicode_binary(), Goal :: unicode:unicode_binary()) -> boolean().
rotate_string(S, Goal) ->
    Len = byte_size(S),
    compute(S, Goal, Len).

compute(_A, _B, 0) -> false;
compute(B, B, _Len) -> true;
compute(<<H, T/binary>>, Goal, Len) ->
    NewBinary = <<T/binary, H>>,
    compute(NewBinary, Goal, Len - 1).