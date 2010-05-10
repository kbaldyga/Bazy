-module(db_login).
-export([validate/2,add_account/3,test/0]).

validate(User,Pass) ->
    Hash = binary_to_list(crypto:md5(Pass)),
    Query = "select pass from user_db where user_login='"++User++"'",
    case database:sql_query(Query) of
        {selected,_X,Response} ->
            if
                element(1,hd(Response)) == Hash ->
                    {ok,User};
                true ->
                    {error,bad_login}
            end ;
        X ->
            {error,X}
    end.

add_account(User,Pass,Email) ->
    Hash = binary_to_list(crypto:md5(Pass)),
    Query = "insert into user_db values(Default,E'"
        ++User++"',E'"++Hash++"',E'"++Email++"');",
    io:format("~p~n",[Query]),
    Response = database:sql_query(Query),
    io:format("Response->~p~n",[Response]).
test()->
    io:format("~p~n",[database:sql_query("select * from user_db")]).
