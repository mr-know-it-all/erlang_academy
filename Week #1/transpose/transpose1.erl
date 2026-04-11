% Copied from:
% https://langintro.com/erlang/article2/


-module(transpose1).
-export([transpose/1]).

transpose(Matrix) -> attach_row(Matrix, []).
  
% Given a matrix and a result, make the first row into a column,
% attach it to the result, and then recursively attach the
% remaining rows to that new result.
% 
% When the original matrix has no rows remaining, the result
% matrix is complete, but each row needs to be reversed. 

attach_row([], Result) ->
  reverse_rows(Result, []);

attach_row(RowList, Result) ->
  [FirstRow | OtherRows] = RowList,
  NewResult = make_column(FirstRow, Result),
  attach_row(OtherRows, NewResult).
                                         
% Make a row into a column. There are three clauses:
% 
% When there are no more entries in the row, the column you are
% making is complete.
% 
% Make the row into a column when the result matrix is empty.
% Create the first item as a singleton list. Follow it with
% the result of making the remaining entries in the column.
% 
% Make a row into a column when the result matrix is not empty.
% Do this by adding the first item at the beginning of the first row of
% the result. That list is followed by the result of making the remainingi
% entries in the column.

make_column([], Result) ->  Result; % my job here is done
  
make_column(Row, []) ->
  [FirstItem | OtherItems] = Row,
  [[FirstItem] | make_column(OtherItems, [])];
  
make_column(Row, Result) ->
  [FirstItem | OtherItems] = Row,
  [FirstRow | OtherRows] = Result,
  [[FirstItem | FirstRow] | make_column(OtherItems, OtherRows)].

% Reverse the order of items in each row of a matrix. This constructs
% a new matrix whose rows are in reverse order, so you need to reverse
% the final result.

reverse_rows([], Result) -> lists:reverse(Result);

reverse_rows(Rows, Result) ->
  [First | Others] = Rows,
  reverse_rows(Others, [lists:reverse(First) | Result]).