-module(records).
-compile(export_all).

-include("records.hrl").

-record(robot, {name,
                type=industrial,
                hobbies,
                details=[]}).

first_robot() ->
    #robot{
            name="Mechatron",
            type=handmade,
            details=["Moved by a small man inside"]
        }.


car_factory(CorpName) ->
    #robot{name=CorpName, hobbies="building cars"}.


%
% Crusher = #robot{name="Crusher", hobbies=["Crushing people","petting cats"]}.
% Crusher#robot.hobbies.
% 
% NestedBot = #robot{details=#robot{name="erNest"}}.
% (NestedBot#robot.details)#robot.name.
% 
% 
% 
% 

-record(user, {id, name, group, age}).

%% use pattern matching to filter
admin_panel(#user{name=Name, group=admin}) ->
    Name ++ " is allowed!";
admin_panel(#user{name=Name}) ->
    Name ++ " is not allowed".

%% can extend user without problem
adult_section(U = #user{}) when U#user.age >= 18 ->
    %% Show stuff that can't be written in such a text
    allowed;
adult_section(_) ->
    %% redirect to sesame street site
    forbidden.

% rr(records).
% records:admin_panel(#user{id=1, name="ferd", group=admin, age=96}).
% records:adult_section(#user{id=21, name="Bill", group=users, age=72}).
% 

repairman(Rob) ->
    Details = Rob#robot.details,
    NewRob = Rob#robot{details=["Repaired by repairman"|Details]},
    {repaired, NewRob}.

% 108> records:repairman(#robot{name="Ulbert", hobbies=["trying to have feelings"], details=["123"]}).
% {repaired,#robot{name = "Ulbert",type = industrial,
%                  hobbies = ["trying to have feelings"],
%                  details = ["Repaired by repairman","123"]}}
% 

included() -> #included{some_field="Some value"}.

% 18> c(records).
% {ok,records}
% 19> rr(records).
% [included,robot,user]
% 20> records:included().
% #included{some_field = "Some value",some_default = "yeah!",
%         unimaginative_name = undefined}