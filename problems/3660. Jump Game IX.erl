% You are given an integer array nums.

% From any index i, you can jump to another index j under the following rules:

% Jump to index j where j > i is allowed only if nums[j] < nums[i].
% Jump to index j where j < i is allowed only if nums[j] > nums[i].
% For each index i, find the maximum value in nums that can be reached by following any sequence of valid jumps starting at i.

% Return an array ans where ans[i] is the maximum value reachable starting from index i.

 

% Example 1:

% Input: nums = [2,1,3]

% Output: [2,2,3]

% Explanation:

% For i = 0: No jump increases the value.
% For i = 1: Jump to j = 0 as nums[j] = 2 is greater than nums[i].
% For i = 2: Since nums[2] = 3 is the maximum value in nums, no jump increases the value.
% Thus, ans = [2, 2, 3].

% Example 2:

% Input: nums = [2,3,1]

% Output: [3,3,3]

% Explanation:

% For i = 0: Jump forward to j = 2 as nums[j] = 1 is less than nums[i] = 2, then from i = 2 jump to j = 1 as nums[j] = 3 is greater than nums[2].
% For i = 1: Since nums[1] = 3 is the maximum value in nums, no jump increases the value.
% For i = 2: Jump to j = 1 as nums[j] = 3 is greater than nums[2] = 1.
% Thus, ans = [3, 3, 3].

 

% Constraints:

% 1 <= nums.length <= 105
% 1 <= nums[i] <= 109


-spec max_value(Nums :: [integer()]) -> [integer()].
max_value(Nums) ->
    MaxPrefix = compute_max_prefix(Nums, []),
    MinSuffix = compute_min_suffix(lists:reverse(Nums), []),
    Result = compute_result(MaxPrefix, MinSuffix, []),
    Result.

% Leave it reversed because to compute result we will go from right to left
compute_max_prefix([], Acc) -> Acc;
compute_max_prefix([Num|Nums], []) -> compute_max_prefix(Nums, [Num]);
compute_max_prefix([Num|Nums], [Last|Acc]) ->
    compute_max_prefix(Nums, lists:append([max(Num, Last)], [Last|Acc])).

% Leave it reversed because to compute result we will go from right to left
compute_min_suffix([], Acc) -> lists:reverse(Acc);
compute_min_suffix([Num|Nums], []) -> compute_min_suffix(Nums, [Num]);
compute_min_suffix([Num|Nums], [Last|Acc]) ->
    compute_min_suffix(Nums, lists:append([min(Num, Last)], [Last|Acc])).


compute_result([], _MinSuffix, Acc) -> Acc;
% When Acc is empty, execution jsut started
% The last value will be maximum from left, there is no other larger one
% We "move" to the left on MaxPref but stay on the MinSuff
% We will compare ith MaxPref with ith + 1 MinSuff
compute_result([Pref|MaxPrefix], MinSuffix, []) ->
    compute_result(MaxPrefix, MinSuffix, [Pref]);
compute_result([Pref|MaxPrefix], [Suff|MinSuffix], [Last|Acc]) ->
    % If ith MaxPref is larger than ith + 1 MinSuff
    % it means that from left we can go to right and there get the maximum that right had
    % the max value in the result will be at last element because from right we can go to any larger left
    case Pref > Suff of
        true -> compute_result(MaxPrefix, MinSuffix, lists:append([Last], [Last|Acc]));
        _ -> compute_result(MaxPrefix, MinSuffix, lists:append([Pref], [Last|Acc]))
    end.

