-module(db_login).
-export([validate/2,add_account/3,test/0,upload_image/0,draw_file/0]).

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
    Response = database:sql_query(Query),
    Response.

test()->
    io:format("~p~n",[database:sql_query("select * from user_db")]).

upload_image() ->
    {ok,File} = file:read_file("c:/image.png"),
    Query = "insert into images values(E'"++binary_to_list(File)++"');",
    case database:sql_query(Query) of
        {error,X} ->
            io:format("~s", [X]);
        X ->
            X
    end.

draw_file() ->
    wf:set_content_type("image/png"),
    Query = "select img from images",
    {selected,_X,Response} = database:sql_query(Query),
    element(1,hd(Response)).
