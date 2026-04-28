% Given a 2D array of characters grid of size m x n, you need to find if there exists any cycle consisting of the same value in grid.

% A cycle is a path of length 4 or more in the grid that starts and ends at the same cell. From a given cell, you can move to one of the cells adjacent to it - in one of the four directions (up, down, left, or right), if it has the same value of the current cell.

% Also, you cannot move to the cell that you visited in your last move. For example, the cycle (1, 1) -> (1, 2) -> (1, 1) is invalid because from (1, 2) we visited (1, 1) which was the last visited cell.

% Return true if any cycle of the same value exists in grid, otherwise, return false.

 

% Example 1:



% Input: grid = [["a","a","a","a"],["a","b","b","a"],["a","b","b","a"],["a","a","a","a"]]
% Output: true
% Explanation: There are two valid cycles shown in different colors in the image below:

% Example 2:



% Input: grid = [["c","c","c","a"],["c","d","c","c"],["c","c","e","c"],["f","c","c","c"]]
% Output: true
% Explanation: There is only one valid cycle highlighted in the image below:

% Example 3:



% Input: grid = [["a","b","b"],["b","z","b"],["b","b","a"]]
% Output: false
 

% Constraints:

% m == grid.length
% n == grid[i].length
% 1 <= m, n <= 500
% grid consists only of lowercase English letters.

% SOLUTION 1:
% TODO: recap solution

-spec contains_cycle(Grid :: [[char()]]) -> boolean().
contains_cycle(Grid) ->
    %% Convert to tuple of tuples for O(1) access: element(Col+1, element(Row+1, Grid))
    TGrid = list_to_tuple([list_to_tuple(Row) || Row <- Grid]),
    Rows = tuple_size(TGrid),
    Cols = tuple_size(element(1, TGrid)),
    find_cycle(TGrid, Rows, Cols, 0, 0, sets:new()).

%% Iterate through each starting point in the grid
%% we reached the end of rows without finding a cycle, return false
find_cycle(_Grid, Rows, _Cols, Rows, _J, _Visited) -> false;
% we reached the end of columns for the current row, move to the next row
find_cycle(Grid, Rows, Cols, I, Cols, Visited) -> find_cycle(Grid, Rows, Cols, I + 1, 0, Visited);
 % we reached a valid cell
find_cycle(Grid, Rows, Cols, I, J, Visited) ->
    case sets:is_element({I, J}, Visited) of
        % the cell wasvisite, we continue searching for a cycle starting from the next cell
        true -> find_cycle(Grid, Rows, Cols, I, J + 1, Visited);
        false ->
            Char = element(J + 1, element(I + 1, Grid)),
            // we start a DFS from the current cell to find a cycle of the same character
            case dfs(Grid, Rows, Cols, I, J, -1, -1, Char, Visited) of
                {true, _} -> true;
                {false, NewVisited} -> find_cycle(Grid, Rows, Cols, I, J + 1, NewVisited)
            end
    end.

%% DFS cycle detection: returns {boolean(), NewVisitedSet}
dfs(Grid, Rows, Cols, R, C, PR, PC, Char, Visited) ->
    case sets:is_element({R, C}, Visited) of
        true -> {true, Visited};
        false ->
            V1 = sets:add_element({R, C}, Visited),
            Neighbors = [
                %% 1. The Output: For every valid move found, add the new {Row, Column} to our list.
                {NR, NC} || 

                %% 2. The Directions: Pick a change in Row (DR) and Column (DC) for Up, Down, Left, and Right.
                {DR, DC} <- [{-1, 0}, {1, 0}, {0, -1}, {0, 1}],

                %% 3. The Math: Calculate the New Row (NR) and New Column (NC) based on current position {R, C}.
                NR <- [R + DR], 
                NC <- [C + DC],

                %% 4. Boundary Check: Ensure the new coordinates are within the grid's dimensions (0 to Max-1).
                NR >= 0, NR < Rows, 
                NC >= 0, NC < Cols,

                %% 5. Value Match: Check if the character at the new position matches the target 'Char'.
                %% (Note: +1 is used because Erlang tuples/lists use 1-based indexing).
                element(NC + 1, element(NR + 1, Grid)) == Char,

                %% 6. Prevent Backtracking: Ensure we aren't moving back to the Previous Row (PR) or Column (PC).
                not (NR == PR andalso NC == PC)
            ],
            check_neighbors(Grid, Rows, Cols, Neighbors, R, C, Char, V1)
    end.

% we have no more neighbors to explore, we return false and the updated visited set
check_neighbors(_Grid, _Rows, _Cols, [], _R, _C, _Char, Visited) -> {false, Visited};
% we have neighbors to explore, we check each one for a cycle.
check_neighbors(Grid, Rows, Cols, [{NR, NC} | T], R, C, Char, Visited) ->
    case dfs(Grid, Rows, Cols, NR, NC, R, C, Char, Visited) of
        {true, V} -> {true, V};
        {false, V} -> check_neighbors(Grid, Rows, Cols, T, R, C, Char, V)
    end.