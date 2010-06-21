-module(db_user).
-compile(export_all).

info(Id) ->
    Query = wf:f("select email,ulica,nr_domu,nr_mieszkania,kod_pocztowy,miasto,telefon  from klient left join dane_kontaktowe using (id_klient) where id_klient=~p",[Id]),
    case database:sql_query(Query) of
        {selected,_Rows,Columns} ->
            [[E,U,D,M,P,Mm,T]] = lists:map(fun(X) ->
                              tuple_to_list(X) end,Columns),
            try
                [E,U,integer_to_list(D),integer_to_list(M),P,Mm,T]
            catch _:_ ->
                [E,U,0,0,P,Mm,T]
            end;
        _Other -> _Other
    end.

update(Email,Ul,Nd,Nm,Kp,M,T) ->
    Test = wf:f("select * from dane_kontaktowe where id_klient=~p",[wf:session(uid)]),
    case database:sql_query(Test) of
        {selected,_R,[]} ->
            X = wf:f("insert into dane_kontaktowe values(~p,'~s',~p,~p,'~s','~s','~s')",[wf:session(uid),Ul,Nd,Nm,Kp,M,T]),
            io:format("~p",[database:sql_query(X)]);
        _Other -> _Other
    end,
    Query = wf:f("update klient set email='~s' where id_klient=~p ; update dane_kontaktowe set ulica='~s', nr_domu=~p, nr_mieszkania=~p,kod_pocztowy='~s',miasto='~s',telefon='~s' where id_klient=~p",[Email,wf:session(uid),Ul,Nd,Nm,Kp,M,T,wf:session(uid)]),
    case database:sql_query(Query) of
        _X ->
             io:format("~p",[_X])
    end.
