-module(category).
-include_lib("nitrogen/include/wf.hrl").
-compile(export_all).

main() ->
    #template { file = "./templates/category.html" }.

title() ->
    "Dodaj now± kategoriê".


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% TABELKA Z PRODUKTAMI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
products_data() ->
    Id = case wf:q("id") of
             undefined -> 0;
             N -> list_to_integer(N)
    end,
    {selected, _Columns, Rows } = db_products_categories:products_from_category(Id),
    lists:map(fun(X) ->
                      tuple_to_list(X) end,Rows).

products_map() ->
    [
     prodId@text,
     prodName@text,
     prodName@url,
     prodDesc@text,
     prodPrice@text,
     prodAvail@text,
     prodPict@image
    ].

products() ->
    Data = products_data(),
    Map = products_map(),
    Body = [
     #table { rows=[
            #tablerow { cells=[
              #tableheader { text="Photo" },
              #tableheader { text="Name" },
              #tableheader { text="Price" },
              #tableheader { text="Available" }]
                      },
            #bind { id=productsTable, data=Data, map=Map,
                    transform=fun products_transform/2,
                    body=#tablerow { id=top, cells=[
                       #tablecell { body=#image { id=prodPict } },
                       #tablecell { body=#link { id = prodName } },
                       #tablecell { id=prodPrice },
                       #tablecell { id=prodAvail }]}}]
              }
           ],
    Body.

products_transform(DataRow,_Acc) ->
    [ Id, Name, _Url, Desc, Price, Avail, Pict] = DataRow,
    { [Id,Name,
       wf:f("product?id=~p",[Id]),
       Desc,wf:f("~w",[Price]),wf:f("~w",[Avail]),
       wf:f("images/produkty/small-~s",[Pict])], _Acc, [] }.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% TABELKA Z KATEGORIAMI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
categories_data() ->
    {selected,_Columns,Rows} = db_products_categories:get_names_count(),
    lists:map(fun(X) ->
                      tuple_to_list(X) end,Rows).

categories_map() ->
    [
     catLink@text,
     catLink@url,
     catId@text,
     catCount@text
    ].

categories() ->
    Data = categories_data(),
    Map = categories_map(),
    [
     #table { rows=[#bind { id=catTable, data=Data, map=Map,
                            transform=fun categories_transform/2,
                      body=#tablerow {id=top, cells=[
                         #tablecell { body=#link { id=catLink } } ] } } ] }
    ].

categories_transform(DataRow,_Acc) ->
    [LinkText,_LinkUrl,Id,Count] = DataRow,
    { [wf:f("~s (~s)",[LinkText,Count]),
       wf:f("category?id=~p",[Id]),
       Id,Count],
      _Acc, [] }.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% DODAWANIE KATEGORII
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

add_category() ->
    [
     #p{},
     #label { text="Nazwa kategorii: " },
     #textbox { id=tb_name, text="", next=ta_description },
     #p {},
     #label { text="Opis: "},
     #textarea { id=ta_description, text="" },
     #flash {},
     #button { text="Dodaj",
               actions=#event{type=click,postback=add}}
    ].


event(add) ->
    io:format("~s~n",[wf:q("tb_name")]),
    case db_categories:add_category(
       wf:q("tb_name"),
       wf:q("ta_description")) of
        {updated,X} ->
            wf:flash(
              wf:f("Database updated! <br>~s row(s) affected",[integer_to_list(X)]));
        {error,X} ->
            wf:flash("Error: ~s",[X])
    end,
    ok;

event(_) ->
    ok.
