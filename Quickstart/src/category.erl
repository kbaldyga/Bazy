-module(category).
-include_lib("nitrogen/include/wf.hrl").
-compile(export_all).

main() ->
    #template { file = "./templates/index.html" }.

title() ->
    "SuperShop".


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
     #table { class="sample", rows=[
            #tablerow { cells=[
              #tableheader { style="width:107px;",text="Photo" },
              #tableheader { style="width:100px;",text="Name" },
              #tableheader { style="width:200px;",text="Description" },
              #tableheader { style="width:40px;",text="Price" },
              #tableheader { style="width:40px;",text="Avail." }]
                      },
            #bind { id=productsTable, data=Data, map=Map,
                    transform=fun products_transform/2,
                       body=#tablerow { id=top, cells=[
                       #tablecell { style="width:107px;", body=#image { id=prodPict } },
                       #tablecell { style="width:100px;",body=#link { id = prodName } },
                       #tablecell { style="width:200px;",id=prodDesc },
                       #tablecell { style="width:40px;",id=prodPrice },
                       #tablecell { style="width:40px;",id=prodAvail } ] } } ] }

           ],
    Body.

products_transform(DataRow,_Acc) ->
    [ Id, Name, _Url, Desc, Price, Avail, Pict] = DataRow,
    Photo = case filelib:is_file(wf:f("static/images/produkty/small-~s",[Pict])) of
                true ->
                    wf:f("images/produkty/small-~s",[Pict]);
                false ->
                    "images/produkty/no_image.jpg"
            end,
    Av = if
             Avail > 0 ->
                 "Yes!";
             true ->
                 "No"
        end,
    { [Id,Name,
       wf:f("product?id=~p",[Id]),
       Desc,wf:f("~w eur",[Price]),wf:f("~s",[Av]),
       Photo], _Acc, [] }.


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
     #bind { id=catTable, data=Data, map=Map,
                            transform=fun categories_transform/2,
                      body=[
                         "<li>",
                         #link { id=catLink, class=none } ,
                         "</li>"] },
     #p{},
     #link { text="Koszyk", url=cart },"</br>",
     #link { text="Panel klienta", url=klient}
    ].

categories_transform(DataRow,_Acc) ->
    [LinkText,_LinkUrl,Id,Count] = DataRow,
    { [wf:f("~s (~s)",[LinkText,Count]),
       wf:f("category?id=~p",[Id]),
       Id,Count],
      _Acc, [] }.

event(_) ->
    ok.
