-module(db_login).
-export([validate/2,add_account/3,get_id/1]).

validate(User,Pass) ->
    Query=wf:f("select * from f_sprawdz_login_haslo('~s','~s')",[User,Pass]),
    case database:sql_query(Query) of
        {selected,["f_sprawdz_login_haslo"],[{"1"}]} ->
            wf:session(uid,get_id(User)),
            {ok,User};
        _X ->
            io:format("~p",[_X]),
            {error,_X}
    end.

add_account(User,Pass,Email) ->
    Query=wf:f("select * from f_nowy_uzytkownik('~s','~s','~s')",[User,Pass,Email]),
    case database:sql_query(Query) of
        {selected,_Rows,_Columns} ->
            wf:session(uid,get_id(User)),
            ok;
        _X ->
            _X
    end.

get_id(User) ->
    Query = "select id_klient from klient where login='"++User++"'",
    case database:sql_query(Query) of
        {selected,_Rows,[{Id}]} ->
            Id;
        _Other -> 0
    end.
