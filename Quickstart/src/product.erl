-module(product).
-include_lib("nitrogen/include/wf.hrl").
-compile(export_all).

main() ->
    #template { file = "./templates/product.html" }.

title() ->
    "Dodaj nowy produkt".

add_product() ->
    wf:session(products,sets:new()),
    Body = [
     #p{},
     #label { text="Product name: " },
     #textbox { id=tb_name, text="", next=ta_description },
     #p {},
     #label { text="Short description: "},
     #textarea { id=ta_description, text="" },
     #label { text="Long description: "},
     #textarea { id=ta_ldescription, text="", style=" height: 200px" },
     #label { text="Price: " },
     #textbox { id=tb_price, text="" },
     #label { text="Available" },
     #textbox { id=tb_available, text="" },
     #flash {},
     #label { text="Photo" },
     #upload { tag=img_upload , show_button=false},
     #button { id=btn_add, text="Add",
               actions=#event{type=click,postback=add}}
           ],
    Body.

categories_data() ->
    {selected,_Columns, Rows} = db_categories:read_all(),
    lists:map(fun(X) ->
                      tuple_to_list(X) end,Rows).

categories_map() ->
    [
     idButton@postback,
     nameLabel@text,
     descriptionLabel@text
    ].


categories() ->
    Data = categories_data(),
    Map = categories_map(),
    [
     #flash { },
     #label { id=labelInfo, text="" },
     #h2 { text = "Select categories" },
     #table { class=tiny, rows=[
        #tablerow { cells=[
             #tableheader { text="Select" },
             #tableheader { text="Name" },
             #tableheader { text="Description"},
             #tableheader { }
        ]},
        #bind { id=catTable, data=Data, map=Map,
                transform=fun alternate_color/2,
                body=#tablerow {id=top,cells=[
%                  #tablecell { body=#button { id=idButton, text=" select" } },
                  #tablecell { body=#checkbox { id=idButton, text=" select" } },
                  #tablecell { id=nameLabel },
                  #tablecell { id=descriptionLabel }
                ]}}
     ]}
    ].

event(ID) when is_integer(ID) ->

    New = case wf:session(products) of
        undefined ->
            S = sets:new(),
            sets:add_element(ID,S);
        S ->
            case sets:is_element(ID,S) of
                true ->
                    sets:del_element(ID,S);
                false  ->
                    sets:add_element(ID,S)
           end
    end,
    wf:session(products,New),
    C = db_categories:category_name(ID),
    wf:update(labelInfo, wf:f("Changed: ~s. Now in ~p categories",[C,length(sets:to_list(New))])),
    ok;


event(add) ->
    %% db_categories:add_category(
    %%   wf:q("tb_name"),
    %%   wf:q("ta_description")),
    Name = wf:q("tb_name"),
    SD = wf:q("ta_description"),
    LD = wf:q("ta_ldescription"),
    Price = wf:q("tb_price"),
    A = wf:q("tb_available"),
    Photo = case wf:session(image) of
        undefined -> "" ;
        X -> X
    end,
    db_products:add_product(Name,SD,LD,Price,A,Photo,sets:to_list(wf:session(products))),
    %wf:session(products,sets:new()),
    wf:flash("Database updated!"),
    ok;

event(_) ->
    ok.
start_upload_event(img_upload) ->
    wf:flash("Started uploading...").
finish_upload_event(_Tag,unfinished,_,_) ->
    wf:flash("Undefined error"),
    ok;
finish_upload_event(_Tag, FileName, LocalFileData, _Node) ->
    Name = lists:nth(3,string:tokens(LocalFileData,"/")),
    image:resize(LocalFileData, wf:f("static/images/produkty/small-~s.jpg",[Name]),100,100),
    image:resize(LocalFileData,wf:f("static/images/produkty/big-~s.jpg",[Name]),300,300),
    wf:flash([
              #label { text=FileName },
              #image { image=wf:f("images/produkty/small-~s.jpg",[Name]) }
             ]),
    wf:session(image,wf:f("~s.jpg",[Name])),
    ok.


%%% ALTERNATE BACKGROUND COLORS %%%
alternate_color(DataRow, Acc) when Acc == []; Acc==odd ->
    {DataRow, even, {top@style, "background-color: #eee;"}};

alternate_color(DataRow, Acc) when Acc == even ->
    {DataRow, odd, {top@style, "background-color: #ddd;"}}.