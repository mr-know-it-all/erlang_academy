% You are given an integer array nums.

% A tuple (i, j, k) of 3 distinct indices is good if nums[i] == nums[j] == nums[k].

% The distance of a good tuple is abs(i - j) + abs(j - k) + abs(k - i), where abs(x) denotes the absolute value of x.

% Return an integer denoting the minimum possible distance of a good tuple. If no good tuples exist, return -1.

 

% Example 1:

% Input: nums = [1,2,1,1,3]

% Output: 6

% Explanation:

% The minimum distance is achieved by the good tuple (0, 2, 3).

% (0, 2, 3) is a good tuple because nums[0] == nums[2] == nums[3] == 1. Its distance is abs(0 - 2) + abs(2 - 3) + abs(3 - 0) = 2 + 1 + 3 = 6.

% Example 2:

% Input: nums = [1,1,2,3,2,1,2]

% Output: 8

% Explanation:

% The minimum distance is achieved by the good tuple (2, 4, 6).

% (2, 4, 6) is a good tuple because nums[2] == nums[4] == nums[6] == 2. Its distance is abs(2 - 4) + abs(4 - 6) + abs(6 - 2) = 2 + 2 + 4 = 8.

% Example 3:

% Input: nums = [1]

% Output: -1

% Explanation:

% There are no good tuples. Therefore, the answer is -1.

 

% Constraints:

% 1 <= n == nums.length <= 100
% 1 <= nums[i] <= n
% 

% SOLUTION 1:
% Notes: Not optimal, but works with the constraints

minimum_distance(Nums) when length(Nums) < 3 -> -1;
minimum_distance(Nums) ->
    NumsTup = list_to_tuple(Nums),
    Len = tuple_size(NumsTup),
    Map = #{},
    Infinity = 1000000000,
    
    Result = compute(1, Len, NumsTup, Map, Infinity),
    
    if Result == Infinity -> -1;
       true -> Result
    end.

compute(I, Len, Nums, Map, Min) when I =< Len ->
    % Val is element at current index in Nums tuple
    Val = element(I, Nums),
    
    NewMin = case maps:find(Val, Map) of
        % current Val was seen before, it will be A
        {ok, A} -> 
            % B will be the current index of Val
            B = I,
            % we continue searching for the third instance of Val
            find_C(I + 1, Len, Val, Nums, A, B, Min);
        error -> 
            Min
    end,
    
    % We add the current Index for Val
    % It can later become A for the next instance of Val
    compute(I + 1, Len, Nums, Map#{Val => I}, NewMin);
compute(_I, _Len, _Nums, _Map, Min) ->
    Min.

find_C(J, Len, Target, Nums, A, B, Min) when J =< Len ->
    case element(J, Nums) of
        % Target equals to our Val
        Target -> 
            C = J,
            Dist = (B - A) + (C - B) + (C - A),
            erlang:min(Min, Dist);
        _ -> 
            find_C(J + 1, Len, Target, Nums, A, B, Min)
    end;
find_C(_J, _Len, _Target, _Nums, _A, _B, Min) ->
    Min.