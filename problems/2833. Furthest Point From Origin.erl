% ou are given a string moves of length n consisting only of characters 'L', 'R', and '_'. The string represents your movement on a number line starting from the origin 0.

% In the ith move, you can choose one of the following directions:

% move to the left if moves[i] = 'L' or moves[i] = '_'
% move to the right if moves[i] = 'R' or moves[i] = '_'
% Return the distance from the origin of the furthest point you can get to after n moves.

 

% Example 1:

% Input: moves = "L_RL__R"
% Output: 3
% Explanation: The furthest point we can reach from the origin 0 is point -3 through the following sequence of moves "LLRLLLR".
% Example 2:

% Input: moves = "_R__LL_"
% Output: 5
% Explanation: The furthest point we can reach from the origin 0 is point -5 through the following sequence of moves "LRLLLLL".
% Example 3:

% Input: moves = "_______"
% Output: 7
% Explanation: The furthest point we can reach from the origin 0 is point 7 through the following sequence of moves "RRRRRRR".
 

% Constraints:

% 1 <= moves.length == n <= 50
% moves consists only of characters 'L', 'R' and '_'.

% SOLUTION !:

-spec furthest_distance_from_origin(Moves :: unicode:unicode_binary()) -> integer().
furthest_distance_from_origin(Moves) ->
    max(compute(Moves, $L, 0), compute(Moves, $R, 0)).

compute(<<>>, _WildcardAs, Pos) ->
    abs(Pos);
compute(<<Char, Moves/binary>>, WildcardAs, Pos) ->
    NextPos = case Char of
        $L -> Pos - 1;
        $R -> Pos + 1;
        $_ -> if WildcardAs =:= $L -> Pos - 1; true -> Pos + 1 end
    end,
    compute(Moves, WildcardAs, NextPos).

% SOLUTION 2:

-spec furthest_distance_from_origin(Moves :: unicode:unicode_binary()) -> integer().
furthest_distance_from_origin(Moves) ->
    {L, R, Underscores} = count_moves(Moves, 0, 0, 0),
    %% The max distance is either all underscores going Left or all going Right
    abs(L - R) + Underscores.

count_moves(<<>>, L, R, U) -> 
    {L, R, U};
count_moves(<<$L, Rest/binary>>, L, R, U) -> 
    count_moves(Rest, L + 1, R, U);
count_moves(<<$R, Rest/binary>>, L, R, U) -> 
    count_moves(Rest, L, R + 1, U);
count_moves(<<$_, Rest/binary>>, L, R, U) -> 
    count_moves(Rest, L, R, U + 1).