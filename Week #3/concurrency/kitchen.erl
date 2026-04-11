-module(kitchen).
-compile(export_all).

fridge1() ->
    receive
        {From, {store, _Food}} ->
            From ! {self(), ok},
            fridge1();
        {From, {take, _Food}} ->
            %% uh....
            From ! {self(), not_found},
            fridge1();
        terminate ->
            ok
    end.

fridge2(FoodList) ->
    receive
        {From, {store, Food}} ->
            From ! {self(), ok},
            fridge2([Food|FoodList]);
        {From, {take, Food}} ->
            case lists:member(Food, FoodList) of
                true ->
                    From ! {self(), {ok, Food}},
                    % it runs itself egain, will have same Pid across executions
                    fridge2(lists:delete(Food, FoodList));
                false ->
                    From ! {self(), not_found},
                    fridge2(FoodList)
            end;
        terminate ->
            ok
    end.

store(Pid, Food) ->
    % self() is the process that executes this function
    % if we run from the shell, it is the shell process
    % 
    Pid ! {self(), {store, Food}},
    io:format("Storing ~p in the fridge...~n", [self()]),
    receive
        {Pid, Msg} -> 
            % Pid is the fridge process, Msg is the response from the fridge
            % Pid = spawn(kitchen, fridge2, [[baking_soda]]).
            % store(Pid, chocolate).

            % Because it runs itself again it will have same PId across exections
            % 
            % 152> kitchen:store(Pid, water).
            % Storing <0.927.0> in the fridge...
            % Received response from fridge: <0.974.0>
            % ok
            % 153> kitchen:store(Pid, water).
            % Storing <0.927.0> in the fridge...
            % Received response from fridge: <0.974.0>
            % ok
            % 154> kitchen:store(Pid, water).
            % Storing <0.927.0> in the fridge...
            
            io:format("Received response from fridge: ~p~n", [Pid]),
            Msg
    end.

take(Pid, Food) ->
    Pid ! {self(), {take, Food}},
    io:format("Taking ~p from the fridge...~n", [self()]),
    receive
        {Pid, Msg} -> 
            io:format("Received response from fridge: ~p~n", [Pid]),
            Msg
    end.

start(FoodList) ->
    spawn(?MODULE, fridge2, [FoodList]).


store2(Pid, Food) ->
    Pid ! {self(), {store, Food}},
    receive
        {Pid, Msg} -> Msg
    after 3000 ->
        timeout
    end.

take2(Pid, Food) ->
    Pid ! {self(), {take, Food}},
    receive
        {Pid, Msg} -> Msg
    after 3000 ->
        timeout
    end.