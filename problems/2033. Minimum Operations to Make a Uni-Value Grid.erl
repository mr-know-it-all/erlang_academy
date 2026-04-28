% You are given a 2D integer grid of size m x n and an integer x. In one operation, you can add x to or subtract x from any element in the grid.

% A uni-value grid is a grid where all the elements of it are equal.

% Return the minimum number of operations to make the grid uni-value. If it is not possible, return -1.

 

% Example 1:


% Input: grid = [[2,4],[6,8]], x = 2
% Output: 4
% Explanation: We can make every element equal to 4 by doing the following: 
% - Add x to 2 once.
% - Subtract x from 6 once.
% - Subtract x from 8 twice.
% A total of 4 operations were used.
% Example 2:


% Input: grid = [[1,5],[2,3]], x = 1
% Output: 5
% Explanation: We can make every element equal to 3.
% Example 3:


% Input: grid = [[1,2],[3,4]], x = 2
% Output: -1
% Explanation: It is impossible to make every element equal.
 

% Constraints:

% m == grid.length
% n == grid[i].length
% 1 <= m, n <= 105
% 1 <= m * n <= 105
% 1 <= x, grid[i][j] <= 104

% SOLUTION 1:
% TLE

-spec min_operations(Grid :: [[integer()]], X :: integer()) -> integer().
min_operations(Grid, X) ->
    FlatNums = flatten(Grid, []),
    SortedFlatNums = lists:sort(FlatNums),
    N = length(FlatNums),
    MidIndex = N div 2 + 1,
    Mid = lists:nth(MidIndex, SortedFlatNums),
    compute(SortedFlatNums, Mid, X, 0).

flatten([], Acc) -> Acc;
flatten([Row|Rows], Acc) ->
    flatten(Rows, Acc ++ Row).

compute([], _Mid, _X, Acc) -> Acc;
compute([Num|Nums], Mid, X, Acc) ->
    Diff = abs(Num - Mid),
    case ((Diff rem X) /= 0) of
        true -> -1;
        false -> compute(Nums, Mid, X, Acc + Diff div X)
    end.

% SOLUTION 2:

-spec min_operations(Grid :: [[integer()]], X :: integer()) -> integer().
min_operations(Grid, X) ->
    FlatNums = lists:append(Grid),
    SortedFlatNums = lists:sort(FlatNums),
    N = length(FlatNums),
    MidIndex = N div 2 + 1,
    % Median value in sorted list will be the element we change to
    Mid = lists:nth(MidIndex, SortedFlatNums),
    compute(SortedFlatNums, Mid, X, 0).

compute([], _Mid, _X, Acc) -> Acc;
compute([Num|Nums], Mid, X, Acc) ->
    % This is the ammount we need to change to get from any element to desired (Median) element
    Diff = abs(Num - Mid),
    % If that difference cannot be composed with X additions or removals we stop
    case ((Diff rem X) /= 0) of
        true -> -1;
        % Else we add to result the number of X operations needed
        false -> compute(Nums, Mid, X, Acc + Diff div X)
    end.