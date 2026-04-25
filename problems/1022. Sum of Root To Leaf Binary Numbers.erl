% You are given the root of a binary tree where each node has a value 0 or 1. Each root-to-leaf path represents a binary number starting with the most significant bit.

% For example, if the path is 0 -> 1 -> 1 -> 0 -> 1, then this could represent 01101 in binary, which is 13.
% For all leaves in the tree, consider the numbers represented by the path from the root to that leaf. Return the sum of these numbers.

% The test cases are generated so that the answer fits in a 32-bits integer.

 

% Example 1:


% Input: root = [1,0,1,0,1,0,1]
% Output: 22
% Explanation: (100) + (101) + (110) + (111) = 4 + 5 + 6 + 7 = 22
% Example 2:

% Input: root = [0]
% Output: 0
 

% Constraints:

% The number of nodes in the tree is in the range [1, 1000].
% Node.val is 0 or 1.

% SOLUTION 1:

%% Definition for a binary tree node.
%%
%% -record(tree_node, {val = 0 :: integer(),
%%                     left = null  :: 'null' | #tree_node{},
%%                     right = null :: 'null' | #tree_node{}}).

-spec sum_root_to_leaf(Root :: #tree_node{} | null) -> integer().
sum_root_to_leaf(Root) ->
    compute(Root, 0).

compute(null, _Num) ->
    0;
compute(Root, Num) ->
    Val = Root#tree_node.val,
    LeftNode = Root#tree_node.left,
    RightNode = Root#tree_node.right,
    NewNum = (Num bsl 1) + Val,
    if LeftNode == null andalso RightNode == null ->
        NewNum;
    true ->
        Left = compute(LeftNode, NewNum),
        Right = compute(RightNode, NewNum),
        Right + Left
    end.