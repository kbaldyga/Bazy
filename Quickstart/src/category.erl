-module(category).
-include_lib("nitrogen/include/wf.hrl").
-compile(export_all).

main() ->
    #template { file = "./templates/category.html" }.

title() ->
    "Dodaj now± kategoriê".

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
