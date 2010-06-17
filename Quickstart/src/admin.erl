-module(admin).
-include_lib("nitrogen/include/wf.hrl").
-compile(export_all).

main() ->
    #template { file = "./templates/admin.html" }.

title() ->
    "Admin control page".

content() ->
    case wf:user() of
        "admin" ->
            add_category();
        _X ->
            wf:redirect_to_login("login")
    end.
content2() ->
    add_product().
content3() ->
    add_to_categories().

categories() ->
    category:categories() ++
        [ "</br></br>", #link { text="Zlecenia", url=zlecenia } ].





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% DODAWANIE KATEGORII
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

add_category() ->
    [
     #p{},
     "<font size=5 color=red>Dodaj kategorie</font></br>",
     #label { text="Nazwa kategorii: " },"</br>",
     #textbox { id=tb_name, text="", next=ta_description },"</br>",
     #p {},
     #label { text="Opis: "},"</br>",
     #textarea { id=ta_description, text="" },"</br>",
     #flash {},"</br>",
     #button { text="Dodaj",
               actions=#event{type=click,postback=add}}
    ].


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%  ADD PRODUCT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
add_product() ->
    wf:session(products,sets:new()),
    Body = [
     #p{},
     "<font size=5 color=red>Dodaj produkt</font></br>",
     #label { text="Product name: " },"</br>",
     #textbox { id=tb_pname, text="", next=ta_pdescription },"</br>",
     #p {},
     #label { text="Short description: "},"</br>",
     #textarea { id=ta_pdescription, text="" },"</br>",
     #label { text="Long description: "},"</br>",
     #textarea { id=ta_ldescription, text="", style=" height: 200px" },"</br>",
     #label { text="Price: " },"</br>",
     #textbox { id=tb_price, text="" },"</br>",
     #label { text="Available" },"</br>",
     #textbox { id=tb_available, text="" },"</br>",
     #flash {},
     #label { text="Photo" },"</br>",
     #upload { tag=img_upload , show_button=false},"</br>",
     #button { id=btn_add, text="Add",
               actions=#event{type=click,postback=padd}}
           ],
    Body.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%  SELECT CATEGORY
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
add_to_categories_data() ->
    {selected,_Columns, Rows} = db_categories:read_all(),
    lists:map(fun(X) ->
                      tuple_to_list(X) end,Rows).

add_to_categories_map() ->
    [
     idButton@postback,
     nameLabel@text,
     descriptionLabel@text
    ].


add_to_categories() ->
    Data = add_to_categories_data(),
    Map = add_to_categories_map(),
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
                  #tablecell { body=#checkbox { id=idButton, text="" } },
                  #tablecell { id=nameLabel },
                  #tablecell { id=descriptionLabel }
                ]}}
     ]}
    ].
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%  EVENTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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


event(padd) ->
    %% db_categories:add_category(
    %%   wf:q("tb_name"),
    %%   wf:q("ta_description")),
    Name = wf:q("tb_pname"),
    SD = wf:q("ta_pdescription"),
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
