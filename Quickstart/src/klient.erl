-module(klient).
-include_lib("nitrogen/include/wf.hrl").
-compile(export_all).

main() ->
    #template { file="./templates/klient.html" }.

title() ->
    "SuperShop - informacje o kliencie".

klient_data() ->
    case wf:user() of
        "admin" ->
            case wf:q("id") of
                undefined ->
                    db_user:info(wf:session(uid)) ;
                N -> db_user:info(list_to_integer(N))
            end ;
        undefined -> wf:redirect_to_login("login") ;
        _X -> db_user:info(wf:session(uid))
    end.

categories() ->
    category:categories().


klient() ->
    Data = klient_data(),
    Body =
      [
       #label { text="wymagane sa wszystkie pola, nr domu, oraz nr. mieszkania musza bya cyframi. kod pocztowy musi miec dlugosc 6 znakow. telefon 9" },
       #flash{},"</br></br>",
       #label { text="email" },"</br>",
       #textbox { text=lists:nth(1,Data),id=email},"</br>",
       #label { text="ulica" },"</br>",
       #textbox { text=lists:nth(2,Data),id=ulica},"</br>",
       #label { text="nr domu" },"</br>",
       #textbox { text=lists:nth(3,Data),id=nrd},"</br>",
       #label { text="nr mieszkania" },"</br>",
       #textbox { text=lists:nth(4,Data),id=nrm},"</br>",
       #label { text="kod pocztowy" },"</br>",
       #textbox { text=lists:nth(5,Data),id=kpcz},"</br>",
       #label { text="miasto" },"</br>",
       #textbox { text=lists:nth(6,Data),id=miasto},"</br>",
       #label { text="telefon" },"</br>",
       #textbox { text=lists:nth(7,Data),id=telefon},"</br></br>",
       #button { id=btn, text="Zapisz", actions=#event{type=click,postback=save}}
       %#label { text = "dane klienta:" },"</br>",
       %Data
      ],
    Body.

event(save) ->
    try
    db_user:update(wf:q("email"),wf:q("ulica"),
                   list_to_integer(wf:q("nrd")),
                   list_to_integer(wf:q("nrm")),
                   wf:q("kpcz"),wf:q("miasto"),wf:q("telefon")),
    wf:flash("Zaktualizowano dane")
    catch _:_ ->
            wf:flash("wymagane s± wszystkie dane w poprawnym formacie")
    end
    .
