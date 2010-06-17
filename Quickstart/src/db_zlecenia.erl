-module(db_zlecenia).
-compile(export_all).

data() ->
    Query = "select id_zamowienie, id_produkt, platnosc, email, nazwa From zbior_zamowien join zamowienie using(id_zamowienie) join klient using (id_klient) join produkt using (id_produkt) where czy_obsluzono='f'",
    case database:sql_query(Query) of
        {selected,_Rows,C} ->
            lists:map(fun(X) -> tuple_to_list(X) end, C) ;
        _Other ->
            _Other
    end.

remove(Id) ->
    Query = wf:f("update zamowienie set czy_obsluzono=true where id_zamowienie=~p",[Id]),
    case database:sql_query(Query) of
        _X ->
             %io:format("~p",[_X])
            _X
    end.
