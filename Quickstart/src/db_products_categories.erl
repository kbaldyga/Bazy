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
    Query = "select id_kategoria,count(*) from zbior_kategorii group by id_kategoria",
    database:sql_query(Query).

%% powtórzenie jest "specjalnie", bo nie potrafiê inaczej poprawnie
%% zbindowaæ danych
get_names_count() ->
    Query = "select kategoria.nazwa,kategoria.nazwa,zbior_kategorii.id_kategoria,count(*) from zbior_kategorii join kategoria on kategoria.id_kategoria=zbior_kategorii.id_kategoria group by zbior_kategorii.id_kategoria, kategoria.nazwa",
    database:sql_query(Query).


products_from_category(ID) ->
    Query = case ID of
            0 ->
               "select distinct produkt.id_produkt, produkt.nazwa, produkt.nazwa, produkt.krotki_opis, produkt.cena, produkt.ile_dostepnych, szczegoly.zdjecie from produkt join zbior_kategorii on produkt.id_produkt = zbior_kategorii.id_produkt join szczegoly on szczegoly.id_produkt = produkt.id_produkt";
            Id ->
               wf:f("select produkt.id_produkt, produkt.nazwa, produkt.nazwa, produkt.krotki_opis, produkt.cena, produkt.ile_dostepnych, szczegoly.zdjecie from produkt join zbior_kategorii on produkt.id_produkt = zbior_kategorii.id_produkt join szczegoly on szczegoly.id_produkt = produkt.id_produkt where zbior_kategorii.id_kategoria=~p",[Id])
    end,
    database:sql_query(Query).
