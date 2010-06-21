-module(product).
-include_lib("nitrogen/include/wf.hrl").
-compile(export_all).

main() ->
    #template { file = "./templates/product.html" }.

title() ->
    "SuperShop".

categories() ->
    category:categories().

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%  Product info
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
product_data() ->
    Id = case wf:q("id") of
             undefined -> 0; % wf:redirect("index")
             N -> list_to_integer(N)
         end,
    {selected,_Columns,Rows} = db_products:select_product(Id),
    lists:map(fun(X) ->
                      tuple_to_list(X) end,Rows).

product_map() ->
    [
     prodId@text,
     pr,
     prodName@url,
     prodSDesc@text,
     prodLDesc@text,
     prodPrice@text,
     prodAvail@text,
     prodPict@image
    ].

product() ->
    Data = product_data(),
    Map = product_map(),
    Body = [
            #flash{},
            #bind { id=productsTable, data=Data, map=Map,
                    transform=fun product_transform/2,
                    body=["<h2>",
                          #link { id = prodName } ,"</h2></br>",
                          #image { id=prodPict },"</br>Price: ",
                          #label { id=prodPrice },"</br>Available: ",
                          #label { id=prodAvail },"</br>",
                          #button {text="Add to cart",
                                   actions=#event{type=click,
                                                  postback=add_to_cart}
                                  },
                          #literal { id=prodLDesc } ] }
           ],
    Body.


product_transform(DataRow,_Acc) ->
    [ Id, Name, _Url, Desc, LDesc, Price, Avail, Pict] = DataRow,
    Photo = case filelib:is_file(wf:f("static/images/produkty/big-~s",[Pict])) of
                true ->
                    wf:f("images/produkty/big-~s",[Pict]);
                false ->
                    "images/produkty/no_image.jpg"
            end,
    { [Id,Name,
       wf:f("product?id=~p",[Id]),
       Desc,LDesc, wf:f("~w",[Price]),wf:f("~w",[Avail]),
       Photo], _Acc, [] }.



event(add_to_cart) ->
    Set = case wf:session(koszyk) of
        undefined ->
            S = sets:new(),
            sets:add_element({list_to_integer(wf:q("id")),1},S);
        S ->
            sets:add_element({list_to_integer(wf:q("id")),1},S)
    end,
    wf:session(koszyk,Set),
    wf:flash("Added to cart!");

event(_) ->
    ok.


