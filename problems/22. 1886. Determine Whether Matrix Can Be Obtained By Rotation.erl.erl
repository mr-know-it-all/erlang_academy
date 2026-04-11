$ Solution for transpose copied from:
% https://langintro.com/erlang/article2/
% TODO: internalize copied part of Solution

isSameRow([], []) -> true;
isSameRow(_, []) -> fale;
isSameRow([], _) -> false;
isSameRow([A|As], [B|Bs]) ->
    if A == B -> isSameRow(As, Bs);
    true -> false
    end.

isSame([], []) -> true;
isSame(_, []) -> false;
isSame([], _) -> false;
isSame([RowA|RowsA], [RowB|RowsB]) ->
    SameRow = isSameRow(RowA, RowB),
    if SameRow -> isSameRow(RowsA, RowsB);
    true -> false
    end.


% transpose: Passes the matrix to attach_row with an empty result.
% attach_row (Row 1): Calls make_column to turn [1, 2] into [[1], [2]].
% attach_row (Row 2): Calls make_column to prepend [3, 4] to the previous result, creating [[3, 1], [4, 2]].
% reverse_rows: Since elements were prepended (backwards), it flips each sub-list and the outer list to return the correct transpose: [[1, 3], [2, 4]].


transpose(Matrix) -> attach_row(Matrix, []).

attach_row([], Result) ->
  reverse_rows(Result, []);

attach_row(RowList, Result) ->
  [FirstRow | OtherRows] = RowList,
  NewResult = make_column(FirstRow, Result),
  attach_row(OtherRows, NewResult).    



make_column([], Result) ->  Result;
  
% reusult is empty, first call
% [1, 2] -> [[1], [2]]
make_column(Row, []) ->
  [FirstItem | OtherItems] = Row,
  [[FirstItem] | make_column(OtherItems, [])];
  
% puts first item in first result row, second item in second result row, etc
% Row: [3, 4], Result: [[1], [2]] -> [[3, 1], [4, 2]]
make_column(Row, Result) ->
  [FirstItem | OtherItems] = Row,
  [FirstRow | OtherRows] = Result,
  [[FirstItem | FirstRow] | make_column(OtherItems, OtherRows)].



reverse_rows([], Result) -> lists:reverse(Result);

reverse_rows(Rows, Result) ->
  [First | Others] = Rows,
  reverse_rows(Others, [lists:reverse(First) | Result]).





-spec find_rotation(Mat :: [[integer()]], Target :: [[integer()]]) -> boolean().
find_rotation(Mat, Target) ->
  RotatedMat1 = lists:reverse(transpose(Mat)),
  RotatedMat2 = lists:reverse(transpose(RotatedMat1)),
  RotatedMat3 = lists:reverse(transpose(RotatedMat2)),

  isSame(Mat, Target) or
  isSame(RotatedMat1, Target) or
  isSame(RotatedMat2, Target) or
  isSame(RotatedMat3, Target).