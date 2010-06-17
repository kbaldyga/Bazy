-module(add_account).
-include_lib("nitrogen/include/wf.hrl").
-compile(export_all).

main() ->
    #template { file = "./templates/add_account.html" }.

title() ->
    "SuperShop: Add account".

categories() ->
    category:categories().

content() ->
     [
      #label { text="Nazwa uzytkownika" } ,"</br>",
      #textbox { id=tb_name, text="" },"</br>",
      #label { text="Haslo" },"</br>",
      #textbox { id=tb_pass, text="" }, "</br>",
      #label { text="email" },"</br>",
      #textbox { id=tb_email, text="" }, "</br>",
      #button { text="OK",
                actions=#event{type=click,postback=ok}},
      #flash{}
     ].

event(ok) ->
    case db_login:add_account(wf:q("tb_name"),
                         wf:q("tb_pass"),
                         wf:q("tb_email")) of
        ok ->
            wf:user(wf:q("tb_name")),
            wf:flash("Dodano nowe konto"),
            wf:redirect_from_login("category")
            ;
        _X ->
            wf:redirect_to_login("login")
    end.
