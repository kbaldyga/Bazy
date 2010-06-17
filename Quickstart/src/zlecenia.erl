-module(zlecenia).
-include_lib("nitrogen/include/wf.hrl").
-compile(export_all).

main() ->
    #template { file="./templates/zlecenia.html" }.

title() ->
    "SuperShop - zlecenia".

categories() ->
    case wf:user() of
        "admin" ->
            category:categories();
        _X ->
            wf:redirect_to_login("login")
    end.

zlecenia_data() ->
    db_zlecenia:data().

zlecenia_map() ->
    [
     id_zamowienie@postback,
     id_produkt@text,
     platnosc@text,
     email@text,
     nazwa@text
    ].

zlecenia() ->
    Data = zlecenia_data(),
    Map = zlecenia_map() ,
    Body = [
     #table { class="sample", rows=[
            #tablerow { cells=[
              #tableheader { style="width:47px;",text="id_Z" },
              #tableheader { style="width:40px;",text="id_PR" },
              #tableheader { style="width:100px;",text="platnosc" },
              #tableheader { style="width:100px;",text="email" },
              #tableheader { style="width:200px;",text="nazwa" }]
                      },
            #bind { id=table, data=Data, map=Map,
                    transform=fun transform/2,
                       body=#tablerow { id=top, cells=[
                       #tablecell {style="width:47px;",
                                   body=#button{text="Usun",id=id_zamowienie,
                                                actions=#event{type=click}}},
                       %#tablecell { style="width:17px;", id=id_zamowienie  },
                       #tablecell { style="width:40px;",id=id_produkt },
                       #tablecell { style="width:100px;",id=platnosc },
                       #tablecell { style="width:100px;",id=email },
                       #tablecell { style="width:200px;",id=nazwa } ] } } ] }

           ],
    Body.


transform(DataRow,_Acc) ->
    [A,B,C,D,E] = DataRow,
    N = integer_to_list(B),
    { [A,N,C,D,E],_Acc,[]}.

event(Id) ->
    db_zlecenia:remove(Id),
    wf:redirect_from_login("zlecenia").
