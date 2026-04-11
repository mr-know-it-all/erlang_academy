

make:all().
code:add_patha("ebin").
eunit:test(regis_server).
eunit:test(regis_server, [verbose]).

Q:
fold_tail(Function, Function(H, Acc), T) or
fold_tail(Function, UpdatedAcc, T)?

It should be still TCO but which is preferable?

