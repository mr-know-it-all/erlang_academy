% You are given a string word. A letter is called special if it appears both in lowercase and uppercase in word.

% Return the number of special letters in word.

 

% Example 1:

% Input: word = "aaAbcBC"

% Output: 3

% Explanation:

% The special characters in word are 'a', 'b', and 'c'.

% Example 2:

% Input: word = "abc"

% Output: 0

% Explanation:

% No character in word appears in uppercase.

% Example 3:

% Input: word = "abBCab"

% Output: 1

% Explanation:

% The only special character in word is 'b'.

 

% Constraints:

% 1 <= word.length <= 50
% word consists of only lowercase and uppercase English letters.

-spec number_of_special_chars(Word :: unicode:unicode_binary()) -> integer().
number_of_special_chars(Word) ->
    Chars = string:to_graphemes(Word),
    LowerSet = sets:from_list([C || C <- Chars, string:lowercase([C]) == [C]]),
    UpperSet = sets:from_list([C || C <- Chars, string:uppercase([C]) == [C]]),

    % if Upper Case letter is in Lower Case set, we keep it
    MatchingCasing = [C || C <- sets:to_list(UpperSet), 
                           sets:is_element(hd(string:lowercase([C])), LowerSet)],

    length(MatchingCasing).