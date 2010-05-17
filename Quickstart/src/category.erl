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
