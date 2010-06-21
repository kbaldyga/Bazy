-module(db_panel).
-compile(export_all).

data() ->
    Query = wf:f("select ulica,nr_domu,nr_mieszkania,kod_pocztowy,miasto,telefon  from dane_kontaktowe where id_klient=~p",[wf:session(uid)]),
    case database:sql_query(Query) of
        {selected,_Rows,Columns} ->
            lists:map(fun(X) ->
                              tuple_to_list(X) end,Columns);
        _Other -> _Other
    end.
