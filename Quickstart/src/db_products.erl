-module(db_products).
-compile(export_all).

add_product(Name, SDesc, Price, Available) ->
    add_product(Name,SDesc,"", Price,Available,"",[]).
add_product(Name,SDesc,LDesc, Price,Available, Photo,Categories) ->
    Query = wf:f(
              "insert into produkt values(DEFAULT,'~s','~s',~s,~s) RETURNING produkt_id",
              [Name,SDesc,Price,Available]),
    case database:sql_query(Query) of
        {error,_X} ->
            {error,_X} ;
        {selected,["produkt_id"],Id} ->
            NId = element(1,hd(Id)),
            Query2 = wf:f(
                      "insert into szczegoly values(~p,'~s','~s')",
                      [NId,LDesc,Photo]),
            database:sql_query(Query2),
            db_products_categories:multi_insert(NId,Categories)
    end.
select_product(Id) ->
    Query = case Id of
                0 ->
                    "select distinct produkt.produkt_id, produkt.nazwa, produkt.nazwa, produkt.krotki_opis, szczegoly.dlugi_opis, produkt.cena, produkt.ile_dostepnych, szczegoly.nazwa_zdjecia from produkt join szczegoly on szczegoly.produkt_id = produkt.produkt_id";
                Id ->
                    wf:f("select distinct produkt.produkt_id, produkt.nazwa, produkt.nazwa, produkt.krotki_opis, szczegoly.dlugi_opis, produkt.cena, produkt.ile_dostepnych, szczegoly.nazwa_zdjecia from produkt join szczegoly on szczegoly.produkt_id = produkt.produkt_id where produkt.produkt_id=~p",[Id])
            end,
    database:sql_query(Query).
%get_name(Id) when is_integer(Id) ->
%    get_name(integer_to_list(Id));
get_name(Id) ->
    Query = wf:f("select nazwa from produkt where produkt_id=~p",[Id]),
    { selected, _Columns, [{Name}] } = database:sql_query(Query),
    Name.
get_name_price(Id) ->
    Query = wf:f("select nazwa, cena from produkt where produkt_id=~p", [Id]),
    {selected, _Columns, [{Name,Price}]} = database:sql_query(Query),
    {Name,integer_to_list(Price)}.

get_sum(Products) ->
    Query1 = "drop function suma(integer,integer) cascade ; create function suma(integer,integer) returns integer as ' declare begin return ($2 * (select cena from produkt where produkt_id = $1)) ; end; ' language 'plpgsql';",
    %%lists:foldr(fun({Id,C},Acc) ->
      ok.






