-module(cart).
-include_lib("nitrogen/include/wf.hrl").
-compile(export_all).

main() ->
    #template { file = "./templates/cart.html" }.

title() ->
    "Cart".

categories() ->
    category:categories().

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% CART BIND DATA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cart_content_data() ->
    Content = case wf:session(koszyk) of
                  undefined -> [];
                  Set -> sets:to_list(Set)
              end,
    %% nie wyswietlamy produktow ktorych sztuk w koszyku jest 0
    Z = lists:foldr(fun({X,_I},Acc) ->
                          if
                              _I == 0 -> Acc ;
                              true ->
                                  {Product,Price} = db_products:get_name_price(X),
                                      [[integer_to_list(X),Product,Price]|Acc]
                          end
                              end, [], Content),
    Z.
cart_content_map() ->
    [
     contId@tag,
     contName@text,
     contPrice@text
    ].

cart_content() ->
    Data = cart_content_data(),
    Map = cart_content_map(),
    Body =
        [
         #table { class="sample", rows=[
            #tablerow { cells=[
              #tableheader { style="width:100px;",text="Name" },
              #tableheader { style="width:100px;",text="How much" },
              #tableheader { style="width:100px;",text="Price" }]
                      },
            #bind { id=cartContent, data=Data, map=Map,
                       body=#tablerow { id=top, cells=[
                       #tablecell { style="width:200px;",id=contName },
                       #tablecell { style="width:40px;", body=
                                        #inplace_textbox { id=contId, text="1"} },
                       #tablecell { style="width:100px", id=contPrice }
                       %% #tablecell { style="width:40px", body=
                       %%              #button { id=contId, text="remove",
                       %%                      actions=#event{type=click}  }
                       %%                               } ] } } ] },
                                                       ]}}]},
         #button { id=finish_btn, text="Finish shopping",
                   actions=#event{type=click,postback=finish} },
         #flash{}
        ],
    Body.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%
event(finish) ->
    Cart = sets:to_list(wf:session(koszyk)),
    case wf:user() of
        undefined ->
            wf:redirect_to_login("login");
        _Other ->
            ID = wf:session(uid),
            db_cart:add(Cart,ID),
            wf:flash("Zamowienie zostalo przyjete. Dziekujemy za zainteresowanie oferta"),
            wf:session(koszyk,sets:new())
    end;

event(login) ->
    _User = case wf:user() of
        undefined ->
            wf:redirect_to_login("login");
        X -> X
    end;
event(Id) ->
    io:format("removed-> ~p~n", [Id]),
    ok.
%event(_) ->
%    ok.

inplace_textbox_event(_Tag, Value) ->
    S = wf:session(koszyk),
    E = sets:filter(fun({X,_B}) -> X == list_to_integer(_Tag) end,S),
    %io:format("~p",[E]),
    S2 = sets:del_element(hd(sets:to_list(E)),S),
    S3 = sets:add_element({list_to_integer(_Tag),list_to_integer(Value)},S2),
    wf:session(koszyk,S3),
    %io:format("~p",[sets:to_list(wf:session(koszyk))]),
  Value.
