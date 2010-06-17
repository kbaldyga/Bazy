-module(db_products).
-compile(export_all).

add_product(Name, SDesc, Price, Available) ->
    add_product(Name,SDesc,"", Price,Available,"",[]).
add_product(Name,SDesc,LDesc, Price,Available, Photo,Categories) ->
    Query = wf:f(
              "insert into produkt values(DEFAULT,'~s','~s',~s,~s) RETURNING id_produkt",
              [Name,SDesc,Price,Available]),
    case database:sql_query(Query) of
        {error,_X} ->
            {error,_X} ;
        {selected,["id_produkt"],Id} ->
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
                    "select id_produkt, nazwa, nazwa, krotki_opis, dlugi_opis,cena, ile_dostepnych, zdjecie from produkt_info";
                Id ->
                    wf:f("select id_produkt, nazwa, nazwa, krotki_opis, dlugi_opis,cena, ile_dostepnych, zdjecie from produkt_info where id_produkt=~p",[Id])
            end,
    database:sql_query(Query).
%get_name(Id) when is_integer(Id) ->
%    get_name(integer_to_list(Id));
get_name(Id) ->
    Query = wf:f("select nazwa from produkt_info where id_produkt=~p",[Id]),
    { selected, _Columns, [{Name}] } = database:sql_query(Query),
    Name.
get_name_price(Id) ->
    Query = wf:f("select nazwa, cena from produkt_info where id_produkt=~p", [Id]),
    {selected, _Columns, [{Name,Price}]} = database:sql_query(Query),
    {Name,integer_to_list(Price)}.

%% get_sum(Products) ->
%%     Query1 = "drop function suma(integer,integer) cascade ; create function suma(integer,integer) returns integer as ' declare begin return ($2 * (select cena from produkt where produkt_id = $1)) ; end; ' language 'plpgsql';",
%%     %%lists:foldr(fun({Id,C},Acc) ->
%%       ok.






