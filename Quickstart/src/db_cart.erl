-module(db_cart).
-compile(export_all).

add(Products,Klient) ->
    % utworzenie nowego zamowienia
    Query1 = wf:f("insert into zamowienie values(default,'~p',now(),'',false) returning id_zamowienie",[Klient]),
    % dodanie produktow do bazy zbior_zamowien
    Query2 = case database:sql_query(Query1) of
        {selected,_Rows,[{Id}]} ->
            lists:foldr(fun ({IDprod,_X},Acc) ->
                            wf:f("select * from f_zamow_produkt(~p,~p);",
                                 [IDprod,Id])++Acc end,"",Products);
            %wf:f("select * from f_zamow_produkt(~p,~p)",[1,Id]) ;
         _Other -> _Other
    end,
    case database:sql_query(Query2) of
        _X -> _X
    end.
