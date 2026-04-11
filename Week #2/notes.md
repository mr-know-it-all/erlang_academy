1. Q: Do we have something like proprety baed testing in the erlang ecosystem?

2. Generator tests are like a middle man between erlang code and EUnit. They allow you to write normal erlang code, but instead of returning a value, they return a "Test Set" (a list of test objects)

The EUnit runner then unpacks the test set, runs each test, and reports the results.
Q: Can fixtures work without generator?

3. Q: When we tail optimize function calls, we decrease / lose the positibility to cache the function
result in the stack frame. Does it have any performance implications? I guess it depends on the use case but is there any general rule of thumb?

Example (maybe not the best one):
factorial(0) -> 1;
factorial(N) when N > 0 -> N * factorial(N - 1).

factorial(N) when N >= 0 -> factorial_tail(N, 1).
factorial_tail(0, Acc) -> Acc;
factorial_tail(N, Acc) when N > 0 -> factorial_tail(N - 1, N * Acc). 

4. What data structure you use the most?

5. Is there a map from type of data to data structure, or it depends on the context?

6. Is it custom to store data exernally instead of memory when convinient?

7. Note in the book about timers and the need to be creative while writing tests.
    Is there a pattern / technique to testing programs that have processes crashing?
    Is there a "chaos monkey" correspondant in erlang?

8. Is it custom to use property based testing?

https://www.quviq.com/documentation/eqc/overview-summary.html
