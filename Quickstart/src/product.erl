-module(product).
-include_lib("nitrogen/include/wf.hrl").
-compile(export_all).

main() ->
    #template { file = "./templates/category.html" }.

title() ->
    "Dodaj nowy produkt".

add_product() ->
    [
     #p{},
     #label { text="Product name: " },
     #textbox { id=tb_name, text="", next=ta_description },
     #p {},
     #label { text="Description: "},
     #textarea { id=ta_description, text="" },
     #flash {},
     #p{},
     #upload { tag=img_upload, button_text="Upload image" },
     #button { text="Add",
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
    wf:flash("Started uploading...").
finish_upload_event(_Tag,unfinished,_,_) ->
    wf:flash("Undefined error"),
    ok;
finish_upload_event(_Tag, FileName, LocalFileData, _Node) ->
    image:resize(LocalFileData, wf:f("static/images/produkty/~s",[FileName]),200,200),
    wf:flash([
              #label { text=FileName },
              #image { image=wf:f("images/produkty/~s",[FileName]) }
             ]),
    ok.
