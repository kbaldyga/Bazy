-module(db_products_categories).
-compile(export_all).

insert(Product,Category) ->
    Query = wf:f("insert into zbior_kategorii values(~s,~s);",
                 [Product,Category]),
    case database:sql_query(Query) of
        {updated,_X} ->
            ok;
        _Other ->
            _Other
    end.

multi_insert(_X,[]) ->
    ok;
multi_insert(Product,Categories) when is_list(Categories) ->
    Query = lists:foldr(fun (X,Acc) ->
                       [wf:f("insert into zbior_kategorii values(~p,~p);",
                             [Product,X])|Acc] end,[],Categories),
    case database:sql_query(Query) of
        {updated,_X} ->
            ok;
        _Other ->
            _Other
    end.

get_count() ->
    Query = "select kategoria_id,count(*) from zbior_kategorii group by kategoria_id",
    database:sql_query(Query).

%% powtórzenie jest "specjalnie", bo nie potrafiê inaczej poprawnie
%% zbindowaæ danych
get_names_count() ->
    Query = "select kategoria.nazwa,kategoria.nazwa,zbior_kategorii.kategoria_id,count(*) from zbior_kategorii join kategoria on kategoria.kategoria_id=zbior_kategorii.kategoria_id group by zbior_kategorii.kategoria_id, kategoria.nazwa",
    database:sql_query(Query).


products_from_category(ID) ->
    Query = case ID of
            0 ->
               "select distinct produkt.produkt_id, produkt.nazwa, produkt.nazwa, produkt.krotki_opis, produkt.cena, produkt.ile_dostepnych, szczegoly.nazwa_zdjecia from produkt join zbior_kategorii on produkt.produkt_id = zbior_kategorii.produkt_id join szczegoly on szczegoly.produkt_id = produkt.produkt_id";
            Id ->
               wf:f("select produkt.produkt_id, produkt.nazwa, produkt.nazwa, produkt.krotki_opis, produkt.cena, produkt.ile_dostepnych, szczegoly.nazwa_zdjecia from produkt join zbior_kategorii on produkt.produkt_id = zbior_kategorii.produkt_id join szczegoly on szczegoly.produkt_id = produkt.produkt_id where zbior_kategorii.kategoria_id=~p",[Id])
    end,
    database:sql_query(Query).
