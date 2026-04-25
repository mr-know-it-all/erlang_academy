% You are given two integer arrays, source and target, both of length n. You are also given an array allowedSwaps where each allowedSwaps[i] = [ai, bi] indicates that you are allowed to swap the elements at index ai and index bi (0-indexed) of array source. Note that you can swap elements at a specific pair of indices multiple times and in any order.

% The Hamming distance of two arrays of the same length, source and target, is the number of positions where the elements are different. Formally, it is the number of indices i for 0 <= i <= n-1 where source[i] != target[i] (0-indexed).

% Return the minimum Hamming distance of source and target after performing any amount of swap operations on array source.

 

% Example 1:

% Input: source = [1,2,3,4], target = [2,1,4,5], allowedSwaps = [[0,1],[2,3]]
% Output: 1
% Explanation: source can be transformed the following way:
% - Swap indices 0 and 1: source = [2,1,3,4]
% - Swap indices 2 and 3: source = [2,1,4,3]
% The Hamming distance of source and target is 1 as they differ in 1 position: index 3.
% Example 2:

% Input: source = [1,2,3,4], target = [1,3,2,4], allowedSwaps = []
% Output: 2
% Explanation: There are no allowed swaps.
% The Hamming distance of source and target is 2 as they differ in 2 positions: index 1 and index 2.
% Example 3:

% Input: source = [5,1,2,4,3], target = [1,5,4,2,3], allowedSwaps = [[0,4],[4,2],[1,3],[1,4]]
% Output: 0
 

% Constraints:

% n == source.length == target.length
% 1 <= n <= 105
% 1 <= source[i], target[i] <= 105
% 0 <= allowedSwaps.length <= 105
% allowedSwaps[i].length == 2
% 0 <= ai, bi <= n - 1
% ai != bi

minimum_hamming_distance(Source, Target, AllowedSwaps) ->
    N = length(Source),
    % Initialize Union-Find array: {0, 1, 2, ..., N-1}
    InitialUnion = array:from_list(lists:seq(0, N - 1)),
    
    % Perform Union operations
    FinalUnion = lists:foldl(fun([A, B], Acc) ->
        RootA = find(Acc, A),
        RootB = find(Acc, B),
        if RootA =/= RootB -> array:set(RootA, RootB, Acc);
           true -> Acc
        end
    end, InitialUnion, AllowedSwaps),

    % Source elements to indices for processing
    SourceArr = array:from_list(Source),
    TargetArr = array:from_list(Target),

    % Group element counts by root: #{Root => #{Num => Count}}
    Groups = lists:foldl(fun(I, AccMap) ->
        Root = find(FinalUnion, I),
        Num = array:get(I, SourceArr),
        
        SubMap = maps:get(Root, AccMap, #{}),
        Count = maps:get(Num, SubMap, 0),
        
        maps:put(Root, maps:put(Num, Count + 1, SubMap), AccMap)
    end, #{}, lists:seq(0, N - 1)),

    % Calculate distance by checking Target elements against the Groups
    {_, Distance} = lists:foldl(fun(I, {CurrentGroups, Diff}) ->
        Root = find(FinalUnion, I),
        Num = array:get(I, TargetArr),
        
        SubMap = maps:get(Root, CurrentGroups),
        NumCount = maps:get(Num, SubMap, 0),

        case NumCount of
            0 -> {CurrentGroups, Diff + 1};
            _ -> 
                NewSubMap = maps:put(Num, NumCount - 1, SubMap),
                {maps:put(Root, NewSubMap, CurrentGroups), Diff}
        end
    end, {Groups, 0}, lists:seq(0, N - 1)),

    Distance.

%% Union-Find 'find' with path compression
find(Union, Node) ->
    Parent = array:get(Node, Union),
    if Parent == Node -> Node;
       true -> find(Union, Parent) % Note: true path compression requires returning updated array
    end.
