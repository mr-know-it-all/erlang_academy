% A width x height grid is on an XY-plane with the bottom-left cell at (0, 0) and the top-right cell at (width - 1, height - 1). The grid is aligned with the four cardinal directions ("North", "East", "South", and "West"). A robot is initially at cell (0, 0) facing direction "East".

% The robot can be instructed to move for a specific number of steps. For each step, it does the following.

% Attempts to move forward one cell in the direction it is facing.
% If the cell the robot is moving to is out of bounds, the robot instead turns 90 degrees counterclockwise and retries the step.
% After the robot finishes moving the number of steps required, it stops and awaits the next instruction.

% Implement the Robot class:

% Robot(int width, int height) Initializes the width x height grid with the robot at (0, 0) facing "East".
% void step(int num) Instructs the robot to move forward num steps.
% int[] getPos() Returns the current cell the robot is at, as an array of length 2, [x, y].
% String getDir() Returns the current direction of the robot, "North", "East", "South", or "West".
 

% Example 1:

% example-1
% Input
% ["Robot", "step", "step", "getPos", "getDir", "step", "step", "step", "getPos", "getDir"]
% [[6, 3], [2], [2], [], [], [2], [1], [4], [], []]
% Output
% [null, null, null, [4, 0], "East", null, null, null, [1, 2], "West"]

% Explanation
% Robot robot = new Robot(6, 3); // Initialize the grid and the robot at (0, 0) facing East.
% robot.step(2);  // It moves two steps East to (2, 0), and faces East.
% robot.step(2);  // It moves two steps East to (4, 0), and faces East.
% robot.getPos(); // return [4, 0]
% robot.getDir(); // return "East"
% robot.step(2);  // It moves one step East to (5, 0), and faces East.
%                 // Moving the next step East would be out of bounds, so it turns and faces North.
%                 // Then, it moves one step North to (5, 1), and faces North.
% robot.step(1);  // It moves one step North to (5, 2), and faces North (not West).
% robot.step(4);  // Moving the next step North would be out of bounds, so it turns and faces West.
%                 // Then, it moves four steps West to (1, 2), and faces West.
% robot.getPos(); // return [1, 2]
% robot.getDir(); // return "West"

 

% Constraints:

% 2 <= width, height <= 100
% 1 <= num <= 105
% At most 104 calls in total will be made to step, getPos, and getDir.

-spec robot_init_(Width :: integer(), Height :: integer()) -> any().
robot_init_(Width, Height) ->
    put(w, Width),
    put(h, Height),
    put(x, 0),
    put(y, 0),
    put(dir, <<"East">>),
    put(moved, false).

-spec robot_step(Num :: integer()) -> any().
robot_step(0) -> ok;
robot_step(Num) ->
    W = get(w),
    H = get(h),
    Perimeter = 2 * (W - 1) + 2 * (H - 1),
    
    % Use rem for the optimization
    ActualSteps = Num rem Perimeter,
    
    % If Num > 0, the robot has officially moved
    put(moved, true),
    
    % Perform the movement
    do_move(ActualSteps),
    
    % Special case: If at (0,0) after moving, direction is always "South"
    case {get(x), get(y)} of
        {0, 0} -> put(dir, <<"South">>);
        _ -> ok
    end.

do_move(0) -> ok;
do_move(Num) ->
    X = get(x),
    Y = get(y),
    Dir = get(dir),
    W = get(w),
    H = get(h),
    case Dir of
        <<"East">> ->
            CanMove = (W - 1) - X,
            if Num =< CanMove -> put(x, X + Num);
               true -> put(x, W - 1), put(dir, <<"North">>), do_move(Num - CanMove)
            end;
        <<"North">> ->
            CanMove = (H - 1) - Y,
            if Num =< CanMove -> put(y, Y + Num);
               true -> put(y, H - 1), put(dir, <<"West">>), do_move(Num - CanMove)
            end;
        <<"West">> ->
            CanMove = X,
            if Num =< CanMove -> put(x, X - Num);
               true -> put(x, 0), put(dir, <<"South">>), do_move(Num - CanMove)
            end;
        <<"South">> ->
            CanMove = Y,
            if Num =< CanMove -> put(y, Y - Num);
               true -> put(y, 0), put(dir, <<"East">>), do_move(Num - CanMove)
            end
    end.

-spec robot_get_pos() -> [integer()].
robot_get_pos() ->
    [get(x), get(y)].

-spec robot_get_dir() -> unicode:unicode_binary().
robot_get_dir() ->
    get(dir).