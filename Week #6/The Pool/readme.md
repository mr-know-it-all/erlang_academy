2> make:all([load, {outdir, "ebin"}]).
Recompile: ppool
Recompile: ppool_nagger
Recompile: ppool_serv
Recompile: ppool_sup
Recompile: ppool_supersup
Recompile: ppool_worker_sup
up_to_date
3> ppool:start_link().
{ok,<0.113.0>}
4> ppool:start_pool(nagger, 2, {ppool_nagger, start_link, []}).
{ok,<0.115.0>}
5> ppool:run(nagger, ["finish the chapter!", 10000, 10, self()]).
{ok,<0.119.0>}
6> ppool:run(nagger, ["Watch a good movie", 10000, 10, self()]).
{ok,<0.121.0>}
7> flush().
Shell got {<0.119.0>,"finish the chapter!"}
ok
8> flush().
Shell got {<0.119.0>,"finish the chapter!"}
ok
9> ppool:run(nagger, ["clean up a bit", 10000, 10, self()]).
noalloc

8> ppool:async_queue(nagger, ["Pay the bills", 30000, 1, self()]).
ok
9> ppool:async_queue(nagger, ["Take a shower", 30000, 1, self()]).
ok
10> ppool:async_queue(nagger, ["Plant a tree", 30000, 1, self()]).
ok
<wait a bit>
received down msg
received down msg
11> flush().
Shell got {<0.70.0>,"Pay the bills"}
Shell got {<0.72.0>,"Take a shower"}
<wait some more>
received down msg
12> flush().
Shell got {<0.74.0>,"Plant a tree"}
ok

13> ppool:sync_queue(nagger, ["Pet a dog", 20000, 1, self()]).
{ok,<0.108.0>}
14> ppool:sync_queue(nagger, ["Make some noise", 20000, 1, self()]).
{ok,<0.110.0>}
15> ppool:sync_queue(nagger, ["Chase a tornado", 20000, 1, self()]).
received down msg
{ok,<0.112.0>}
received down msg
16> flush().
Shell got {<0.108.0>,"Pet a dog"}
Shell got {<0.110.0>,"Make some noise"}
ok
received down msg
17> flush().
Shell got {<0.112.0>,"Chase a tornado"}
ok