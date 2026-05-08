% Given the head of a linked list, rotate the list to the right by k places.

 

% Example 1:


% Input: head = [1,2,3,4,5], k = 2
% Output: [4,5,1,2,3]
% Example 2:


% Input: head = [0,1,2], k = 4
% Output: [2,0,1]
 

% Constraints:

% The number of nodes in the list is in the range [0, 500].
% -100 <= Node.val <= 100
% 0 <= k <= 2 * 109

%% Definition for singly-linked list.
%%
%% -record(list_node, {val = 0 :: integer(),
%%                     next = null :: 'null' | #list_node{}}).

rotate_right(null, _) -> null;
rotate_right(Head, K) ->
    
    NativeList = to_list(Head),
    Len = length(NativeList),
    
    Shift = K rem Len,
    {Left, Right} = lists:split(Len - Shift, NativeList),
    Rotated = Right ++ Left,
    
    from_list(Rotated).

to_list(null) -> [];
to_list(#list_node{val = V, next = N}) -> [V | to_list(N)].

from_list([]) -> null;
from_list([H | T]) -> #list_node{val = H, next = from_list(T)}.