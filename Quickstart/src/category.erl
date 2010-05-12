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
     #p{},
     #upload { tag=img_upload, button_text="Prze¶lij obrazek" },
     #button { text="Dodaj",
               actions=#event{type=click,postback=add}}
    ].

event(add) ->
    %% db_categories:add_category(
    %%   wf:q("tb_name"),
    %%   wf:q("ta_description")),
    ok;

event(_) ->
    ok.
start_upload_event(img_upload) ->
    wf:flash("Rozpoczêto przesy³anie...").
finish_upload_event(_Tag,unfinished,_,_) ->
    wf:flash("Wystapil blad"),
    ok;
finish_upload_event(_Tag, FileName, LocalFileData, Node) ->
    FileSize = filelib:file_size(LocalFileData),
    wf:flash(wf:f("Uploaded file: ~s (~p bytes) on node ~s.", [FileName, FileSize, Node])),

    wf:flash([
              #label { text=FileName },
             #image { image=wf:f("images/produkty/~s",[FileName]) }
             ]),
    ok.
